class Lesson < ActiveRecord::Base
  include PgSearch

  # Relations
  has_many :learning_modules, through: :learning_modules_lessons
  has_many :content_pages, -> { order('content_pages_lessons.position ASC') }, through: :content_pages_lessons, after_add: :page_structure_changed!, after_remove: :page_structure_changed!

  has_many :learning_modules_lessons, dependent: :destroy
  has_many :content_pages_lessons, dependent: :destroy

  has_one :text_block, dependent: :destroy
  has_many :course_pages, dependent: :destroy

  # Fields
  attr_accessible :name, :title, :rate_lesson, :content_page_ids, :text_block_attributes
  accepts_nested_attributes_for :text_block

  # Search
  multisearchable :against => [:name]

  PgSearch.multisearch_options = {
    :using => { :tsearch => {:prefix => true}}
  }

  before_validation do
    if self.title.blank?
      self.title = self.name
    end
  end

  # Course pages
  def page_structure_changed!(obj)
    @page_structure_changed = true
  end

  after_save do
    if @page_structure_changed
      generate_course_pages
      @page_structure_changed = false
    end
  end

  # Sorting
  def sort_content_pages(pos_ids)
    pos_ids.each_with_index do |pos_id, i|
      content_pages_lessons.where(content_page_id: pos_id).update_all(position: i+1)
    end

    generate_course_pages
  end

  # Content page by position: first is 1
  def content_page_by_position(position)
    content_pages.offset(position - 1).first
  end

  # Number of children + self
  def page_count
    content_pages.count + 1
  end

  # Iterate descendants
  def descendants(page, level, parent_page, &block)
    block.call self, page, level, parent_page
    self_page = page
    page += 1

    content_pages.each do |content_page|
      if level > 0
        block.call content_page, page, level-1, self_page
      end
      page += 1
    end

    page
  end

  # For all courses
  def generate_course_pages
    courses = Set.new
    learning_modules.each do |learning_module|
      courses += learning_module.courses.to_a
    end

    courses.each do |course|
      course.set_course_pages_changed(true)
    end
  end

  # Quizzes in all courses with this lesson
  def course_quiz_ids
    if learning_modules.empty?
      own_quiz_ids
    else
      all =  { quiz_ids: Set.new, question_ids: Set.new}

      learning_modules.each do |learning_module|
        stat = learning_module.course_quiz_ids
        all[:quiz_ids] += stat[:quiz_ids]
        all[:question_ids] += stat[:question_ids]
      end

      all
    end
  end

  # Quizzes of this lesson
  def own_quiz_ids
    all = { quiz_ids: Set.new, question_ids: Set.new}

    content_pages.each do |content_page|
      stat = content_page.own_quiz_ids
      all[:quiz_ids] += stat[:quiz_ids]
      all[:question_ids] += stat[:question_ids]
    end

    all
  end

  # Quizzes of this lesson
  def quizzes
    all = []
    content_pages.each do |content_page|
      all += content_page.quizzes.to_a
    end

    all
  end

end
