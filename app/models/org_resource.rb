class OrgResource < ActiveRecord::Base
  # Relations
  belongs_to :org, touch: true
  belongs_to :course, touch: true

  # Scopes
  scope :by_key, ->(key, course = nil) { where(org_key: key.try(:upcase), course_id: course) }

  # Fields
  attr_accessible :course_id, :org_key, :org_value
  normalize_attribute :org_key, with: [:squish, :upcase, :blank]
  normalize_attribute :org_value

  # Validations
  validates :org, :org_key, presence: true
  validates :org_key, uniqueness: { scope: :org_id, case_sensitive: false},
                      format: { with: /\A[\w ]+:?[\w ]+\z/i, message: 'Only letters, numbers, colon, space, and _' }
end
