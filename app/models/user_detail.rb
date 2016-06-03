class UserDetail < ActiveRecord::Base
  RACES = ['white', 'black', 'asian', 'hispanic', 'middle eastern', 'indian'].freeze
  GENDERS = ['male', 'female'].freeze

  # Relations
  belongs_to :user
  has_many :courses, through: :users_course

  # Fields
  attr_accessible :gender, :race, :race_map, :multi_race_map
  store_accessor :user_data, :certificate_url, :notifications, :lesson_rates, :gender, :race, :race_map, :pledge_of_inclusion_at, :pledge_of_inclusion_fb_shared

  # Scopes

  # Delegations
  delegate :email, :name, to: :user, prefix: true, allow_nil: false
  delegate :org_name, to: :user, prefix: false, allow_nil: false

  # Validations
  validates :race, inclusion: { in: RACES }, allow_nil: true
  validates :gender, inclusion: { in: GENDERS }, allow_nil: true

  # States
  state_machine :registration_state, initial: :require_name do
    state :require_name
    state :registration_complete

    event :apply_student_name do
      transition :require_name => :registration_complete, if: ->(user_detail) do
        user_detail.user_info_full?
      end
    end
  end

  # Callbacks
  before_create do
    begin
      self.id = SecureRandom.random_number(1_000_000_000)
    end while UserDetail.where(:id => self.id).exists?
  end

  def self.filter(params)
    all = self

    if params[:email].present?
      all = all.joins(:user).where('LOWER(users.email) LIKE ?', "%#{params[:email].downcase}%")
    end

    if params[:name].present?
      name = "%#{params[:name].downcase}%"
      all = all.joins(:user).where('(LOWER(users.first_name) LIKE ?) OR (LOWER(users.last_name) LIKE ?)', name, name)
    end

    if params[:org].present?
      all = all.joins(:user).where('users.org_id = ?', params[:org])
    end

    all = all.order('created_at DESC')

    all
  end

  def self.race_for_select
    @@race_for_select ||= RACES.inject({}) {|memo, obj| memo[obj.titleize] = obj; memo}
  end

  def self.race_map_for_select
    @@race_map_for_select ||= FACE_CONFIG['race_identifiers'].keys
  end

  def user_info_full?
    user.valid?(:check_names)
    # user.valid?(:check_names) && gender.present? && race.present?
  end

  def female?
    gender == 'female'
  end

  def male?
    gender == 'male'
  end

  # Race identifier
  def race=(r)
    self.user_data ||= {}
    user_data['race'] = r
    user_data['race_map'] = FACE_CONFIG['race_identifiers'].key(r)
    user_data_will_change!
  end

  # Race label
  def race_map=(r)
    if FACE_CONFIG['race_identifiers'].include? r
      self.user_data ||= {}
      user_data['race_map'] = r
      user_data['race'] = FACE_CONFIG['race_identifiers'][r]
      user_data_will_change!
    end
  end

  # Multiple race labels
  def multi_race_map
    if user_data && user_data['multi_race_map'].present?
      user_data['multi_race_map'].split(',')
    elsif race_map.present?
      [ race_map ]
    else
      []
    end
  end

  # Assign array ["", "Black", "White"]
  def multi_race_map=(params)
    races = params.uniq.select do |race|
      FACE_CONFIG['race_weights'].include? race
    end

    self.user_data ||= {}
    user_data['multi_race_map'] = races.join(',')
    user_data_will_change!

    primary_race = races.max do |a, b|
      FACE_CONFIG['race_weights'][a] <=> FACE_CONFIG['race_weights'][b]
    end

    self.race = FACE_CONFIG['race_identifiers'][primary_race]
  end

  # Update details
  def update_details(params)
    # user_data['gender'] = params[:gender]
    # if params[:race].present?
    #   self.race = params[:race]
    # elsif params[:race_map].present?
    #   self.race_map = params[:race_map]
    # end

    user.email = params[:email]
    if params[:org].present?
      user.org = Org.find params[:org]
    else
      user.org = nil
    end

    user.save!
    save!
  end

  # Pledge of Inclusion status
  def pledge_of_inclusion_applied?
    pledge_of_inclusion_at.present?
  end

  # Show Pledge of Inclusion modal
  def pledge_of_inclusion_facebook?
    !user.org.try(:skip_pledge_modal?) && !pledge_of_inclusion_fb_shared.true?
  end

  # Update Pledge of Inclusion status
  # params: { :fb_shared => true }
  def update_pledge_of_inclusion(params)
    self.pledge_of_inclusion_fb_shared = (params[:fb_shared] == true || params[:fb_shared] == 'true')
    self.pledge_of_inclusion_at = Time.now

    save
  end
end
