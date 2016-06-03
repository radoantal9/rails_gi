class ContentPage < ActiveRecord::Base
  include PgSearch

  # Relations
  has_many :content_page_elements, -> { order('content_page_elements.position ASC') }, dependent: :destroy

  has_many :content_pages_lessons, dependent: :destroy
  has_many :lessons, through: :content_pages_lessons, after_add: :page_structure_changed!, after_remove: :page_structure_changed!

  has_many :course_pages, dependent: :destroy

  scope :by_lesson, ->(lesson) { joins(:content_pages_lessons).where('content_pages_lessons.lesson_id' => lesson) }

  # Fields
  attr_accessible :name, :title, :lesson_ids

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
    @changed_lessons ||= Set.new(lessons.to_a)
    @changed_lessons << obj
    @page_structure_changed = true
  end

  after_save do
    if @page_structure_changed
      generate_course_pages
      @page_structure_changed = false
      @changed_lessons.clear
    end
  end

  # For all courses
  def generate_course_pages
    @changed_lessons ||= lessons.to_a

    @changed_lessons.each do |lesson|
      lesson.generate_course_pages
    end
  end

  # Quizzes on this page
  def quizzes
    Quiz.joins(:content_page_elements).where('content_page_elements.id' => self.content_page_elements)
  end

  # Text blocks on this page
  def text_blocks
    TextBlock.joins(:content_page_elements).where('content_page_elements.id' => self.content_page_elements)
  end

  # Ungraded questions on this page
  def ungraded_questions
    Question.joins(:content_page_elements).where('content_page_elements.id' => self.content_page_elements)
  end

  # Add page element to list
  def add_element(element)
    if element.content_pages.include?(self)
      false
    else
      content_page_elements.create(element: element)
      true
    end
  end

  # Add elements with id in params[:text_block_ids] and params[:quiz_ids]
  def add_elements(params)
    update_cache = false
    count = 0
    TextBlock.where(id: params[:text_block_ids]).each do |obj|
      count += 1 if add_element(obj)
    end

    Quiz.where(id: params[:quiz_ids]).each do |obj|
      if add_element(obj)
        count += 1
        update_cache = true
      end
    end

    Question.ungraded_questions.where(id: params[:ungraded_question_ids]).each do |obj|
      if add_element(obj)
        count += 1
        update_cache = true
      end
    end

    if update_cache
      generate_course_pages
    end

    count
  end

  # Remove element
  def remove_element(params)
    el = content_page_elements.find(params[:pos_id])
    content = el.element
    el.destroy

    if content.is_a?(Quiz) || content.is_a?(Question)
      generate_course_pages
    end
  end

  # Sorting
  def sort_elements(pos_ids)
    pos_ids.each_with_index do |pos_id, i|
      content_page_elements.where(id: pos_id).update_all(position: i+1)
    end
  end

  # Quizzes in all courses with this content page
  def course_quiz_ids
    if lessons.empty?
      own_quiz_ids
    else
      all = { quiz_ids: Set.new, question_ids: Set.new }

      lessons.each do |lesson|
        stat = lesson.course_quiz_ids
        all[:quiz_ids] += stat[:quiz_ids]
        all[:question_ids] += stat[:question_ids]
      end

      all
    end
  end

  # Quizzes of this content page
  def own_quiz_ids
    {
      quiz_ids: Set.new(quizzes.pluck(:id)),
      question_ids: Set.new(ungraded_questions.pluck(:id))
    }
  end

end
