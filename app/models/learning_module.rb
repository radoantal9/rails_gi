class LearningModule < ActiveRecord::Base
  include PgSearch

  # Relations
  has_many :courses, through: :courses_learning_modules
  has_many :lessons, -> { order('learning_modules_lessons.position ASC') }, through: :learning_modules_lessons, after_add: :page_structure_changed!, after_remove: :page_structure_changed!

  has_many :courses_learning_modules, dependent: :destroy
  has_many :learning_modules_lessons, dependent: :destroy

  has_one :text_block, dependent: :destroy
  has_many :course_pages, dependent: :destroy

  # Fields
  attr_accessible :name, :title, :lesson_ids, :text_block_attributes, :description, :description_image, :description_image_cache, :remove_description_image
  accepts_nested_attributes_for :text_block
  mount_uploader :description_image, DescriptionImageUploader

  # Search
  multisearchable :against => [:name]

  PgSearch.multisearch_options = {
    :using => { :tsearch => {:prefix => true}}
  }

  # Course pages
  def page_structure_changed!(obj)
    @page_structure_changed = true
  end

  before_validation do
    if self.title.blank? 
      self.title = self.name
    end
  end

  after_save do
    if @page_structure_changed
      generate_course_pages
      @page_structure_changed = false
    end
  end

  # Sorting
  def sort_lessons(pos_ids)
    pos_ids.each_with_index do |pos_id, i|
      learning_modules_lessons.where(lesson_id: pos_id).update_all(position: i+1)
    end

    generate_course_pages
  end

  # Lesson by position: first is 1
  def lesson_by_position(position)
    lessons.offset(position - 1).first
  end

  # Number of pages in all descendants + self
  def page_count
    lessons.inject(1) {|memo, obj| memo + obj.page_count }
  end
  
  # Iterate descendants
  def descendants(page, level, &block)
    block.call self, page, level
    self_page = page
    page += 1

    lessons.each do |lesson|
      if level > 0
        page = lesson.descendants(page, level-1, self_page, &block)
      else
        page += lesson.page_count
      end
    end

    page
  end

  # For all courses
  def generate_course_pages
    courses.each do |course|
      course.set_course_pages_changed(true)
    end
  end

  # Quizzes in all courses with this learning_module
  def course_quiz_ids
    if courses.empty?
      own_quiz_ids
    else
      all = { quiz_ids: Set.new, question_ids: Set.new}

      courses.each do |course|
        stat = course.course_quiz_ids
        all[:quiz_ids] += stat[:quiz_ids]
        all[:question_ids] += stat[:question_ids]
      end

      all
    end
  end

  # Quizzes of this learning_module
  def own_quiz_ids
    all = { quiz_ids: Set.new, question_ids: Set.new}

    lessons.each do |lesson|
      stat = lesson.own_quiz_ids
      all[:quiz_ids] += stat[:quiz_ids]
      all[:question_ids] += stat[:question_ids]
    end

    all
  end
end
