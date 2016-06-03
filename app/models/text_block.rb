class TextBlock < ActiveRecord::Base
  include PgSearch

  # Relations
  has_paper_trail
  has_many :content_page_elements, as: :element, dependent: :destroy
  has_many :content_pages, through: :content_page_elements
  belongs_to :course, touch: true
  belongs_to :learning_module, touch: true
  belongs_to :lesson, touch: true

  # Scopes
  scope :for_content_pages, -> { where('(course_id IS NULL) AND (learning_module_id IS NULL) AND (lesson_id IS NULL)') }
  scope :for_courses, -> { where('(course_id IS NOT NULL) OR (learning_module_id IS NOT NULL) OR (lesson_id IS NOT NULL)') }

  # Fields
  attr_accessible :private_title, :raw_content

  multisearchable :against => [:private_title, :raw_content]

  PgSearch.multisearch_options = {
    :using => { :tsearch => {:prefix => true}}
  }

  def parent
    @parent ||= (lesson || learning_module || course)
  end

  def form_label
    "#{id} - #{private_title}"
  end
end
