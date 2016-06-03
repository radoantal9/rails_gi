require 'score_helper'

#todo: update the HTML once so doesn't have to be done on every method call
#todo: reflection question type

class Question < ActiveRecord::Base
  UNGRADED_QUESTIONS = %w(essay gridform guess survey multiple_ungraded).freeze
  QUESTION_PRIVACY = { none: 0, confidential_private: 1,  confidential_anonymous: 2 }.freeze # db default: 0

  include PgSearch

  # Relations
  has_paper_trail
  has_many :content_page_elements, as: :element, dependent: :destroy
  has_many :content_pages, through: :content_page_elements

  has_and_belongs_to_many :quizzes, :join_table => "quizzes_questions"
  accepts_nested_attributes_for :quizzes

  has_many :question_privacies, dependent: :destroy
  has_many :question_responses
  has_many :surveys

  # Scopes
  scope :graded_questions, -> { where("question_type NOT IN (?)", UNGRADED_QUESTIONS) }
  scope :ungraded_questions, -> { where(:question_type => UNGRADED_QUESTIONS) }
  scope :by_question_type, ->(question_type) { where(:question_type => question_type) }

  # Fields
  as_enum :question_privacy, QUESTION_PRIVACY, slim: false
  attr_accessible :content, :title, :name, :retired, :quiz_ids, :question_privacy

  # Validations
  validates :content, :content_hash, presence: true
  validates :title, presence: true, uniqueness: true
  validates :question_type, presence: true

  validate :validate_html_in_content

  @@score_helper = ScoreHelper.new

  before_validation do
    if self.title.blank? 
      self.title = self.name
    end
    if content_changed?
      xmlnode            = Nokogiri::XML.parse(self.content)
      self.question_type = xmlnode.xpath("//question/options/@type").to_s.downcase
    end
  end

  # Search
  multisearchable :against => [:title, :statement, :question_type, :choice_text, 
                               :choice_correct_text, :choice_incorrect_text, 
                               :choice_answer, :choice_match, :item_text, 
                               :item_type, :item_option_value]

  PgSearch.multisearch_options = {
    :using => { :tsearch => {:prefix => true}}
  }

  # Content from storage
  def content
    ContentStorage.by_hash(content_hash).try(:content_data)
  end

  def content=(new_content)
    self.content_hash = ContentStorage.add_content(new_content)
    new_content
  end

  def content_changed?
    content_hash_changed?
  end

  def form_label
    "#{id} - #{title}"
  end

  # Course pages with this question
  def course_pages
    CoursePage.where('question_ids_str LIKE ?', "%|#{id}|%")
  end

  # Org-specific privacy of question
  def org_question_privacy(org)
    privacy = question_privacies.by_org(org)
    #privacy = privacy.by_course(course)
    privacy = privacy.first
    if privacy
      privacy.question_privacy
    else
      self.question_privacy
    end
  end

  def xmlnode
    @xmlnode ||= Nokogiri::XML.parse(self.content)
  end

  # Items of 'survey'
  def self.survey_items(question_content)
    if question_content.present?
      xmlnode = Nokogiri::XML.parse(question_content)
      xmlnode.xpath('//item').map {|x| x['text'] }
    end
  end

  def validate_html_in_content
    errs = Nokogiri::XML.parse(self.content).errors
    # if we have errors, thats an issue
    if errs.count > 0
      errtxt = errs.join(';')
      errors.add(:content, "Invalid HTML #{errs.count} errors; #{errtxt}")
    end

    # todo: make sure there is only ONE score=1 for a single choice question

    # todo: make sure there aren't all score=1 or all score=0 for a multiple choice question
  end

  #################################################################
  def getHtml
    # todo: move this into a proper erb file and send an object instead
    nodeset = Nokogiri::XML.parse(self.content)
    html << "<form>"

    nodeset.xpath('//choice').each do |ch|
      html << "<input type=\"radio\" value=\"#{ch['text']}\">#{ch['text']} <br>"
    end

    html << "</form>"

    return html
  end

  #################################################################
  # todo: What if form_data is blank
  def grade(given_answer, user = nil, given_comment = nil)
    grade_report = QuestionGradeReport.new

    case self.question_type
      when "single"
        #puts "Grading single choice question"
        grade_report = grade_single_choice(given_answer)

      when "multiple"
        #puts "Grading multiple choice question"
        grade_report = grade_multiple_choice(given_answer)

      when "match"
        #puts "Grading match question"
        grade_report = grade_match_question(given_answer)

      when "data_grid"
        #todo: add data grid question type, all AJAX
        puts "Grading daya grid questions"

      when "text_store"
        #todo: Add text type question that only gets stored, no scoring

      when "truefalse"
        #todo: Add true false question type
        grade_report = grade_truefalse_choice(given_answer)

      else
        # todo: Raise exception if we got a question type we dont know how to grade
        puts "ERROR: Do not know how to grade this!!"
    end

    if given_comment
      grade_report.given_answer["comment"] = given_comment.inject({}) do |memo, a|
        name, value = a
        memo[name.downcase] = value if value.present?

        memo
      end
    end

    grade_report.question_privacy = self.org_question_privacy(user.try :org)
    grade_report.content = self.content
    grade_report.question = self
    grade_report.user = user
    grade_report.save!

    return grade_report
  end

  #################################################################
  def grade_single_choice(given_answer)

    grade_report = QuestionGradeReport.new

    # Get the actual question
    # Get the right answer for this question object
    correct_answer_value = self.xmlnode.xpath("//choice[@score='1']/@text").to_s

    #todo: Fix monkey patch of removing quotes from the form values


    # make sure given answer is a simple string, not an array.  If array, get the first value
    if given_answer.kind_of?(Array)
      given_answer_string = given_answer[0]
    else
      given_answer_string = given_answer
    end

    Rails.logger.info "Given answer: [#{given_answer_string}], Right answer: [#{correct_answer_value}]"

    given_answer_hash   = {"question_id" => self.id, "answer" => given_answer_string}
    correct_answer_hash = {"question_id" => self.id, "answer" => correct_answer_value}

    # Create a quiz grade report object and assign it the content of the question
    # We will be saving this for the user
    grade_report.given_answer = given_answer_hash
    grade_report.correct_answer = correct_answer_hash

    if given_answer_string == correct_answer_value
      grade_report.score = 1.0
    else
      grade_report.score = 0.0
    end

    grade_report.details = get_correct_and_incorrect_text

    return grade_report
    #puts grade_report.inspect
  end

  #################################################################
  def grade_multiple_choice(given_answer_array)
    # each answer is graded for weither it matches the results

    grade_report = QuestionGradeReport.new

    correct_answers = self.get_correct_answers
    Rails.logger.info "Given answer: [#{given_answer_array}], Right answer: [#{correct_answers}]"
    
    if given_answer_array.nil?
      given_answer_array = []
    end

    grade_report.score = @@score_helper.multiple_choice(given_answer_array, correct_answers, get_number_of_choices)

    # puts "score #{grade_report.score} correct answers: #{num_of_correct_answers} - correct ans count #{correct_answers.inspect}, #{diff.count}"
    given_answer_hash   = {"question_id" => self.id, "answer" => given_answer_array}
    correct_answer_hash = {"question_id" => self.id, "answer" => correct_answers}

    grade_report.given_answer   = given_answer_hash
    grade_report.correct_answer = correct_answer_hash
    grade_report.details = get_correct_and_incorrect_text

    return grade_report
  end

  #################################################################
  def grade_match_question(given_answer_hash)
    grade_report = QuestionGradeReport.new

    if given_answer_hash
        answer = {}
        given_answer_hash.each do |name, value|
          answer[name.downcase] = value.downcase
        end
      given_answer_hash =  answer
    end

    correct_answers = self.get_correct_answers
    Rails.logger.info "Given answer: [#{given_answer_hash}], Right answer: [#{correct_answers}], get_number_of_choices : #{get_number_of_choices}"

    given_answer_hash ||= {}

    grade_report.score = @@score_helper.truefalse(given_answer_hash, correct_answers, get_number_of_choices)

    grade_report.given_answer = {"question_id" => self.id, "answer" => given_answer_hash}

    grade_report.correct_answer = {"question_id" => self.id, "answer" => correct_answers}

    grade_report.details = get_correct_and_incorrect_text

    return grade_report
  end

  #################################################################
  def grade_truefalse_choice(given_answer_hash)
    grade_report = QuestionGradeReport.new

    if given_answer_hash
        answer = {}
        given_answer_hash.each do |name, value|
          answer[name.downcase] = value
        end
      given_answer_hash =  answer
    end

    correct_answers = self.get_correct_answers
    Rails.logger.info "Given answer: [#{given_answer_hash}], Right answer: [#{correct_answers}], get_number_of_choices : #{get_number_of_choices}"

    given_answer_hash ||= {}

    grade_report.score = @@score_helper.truefalse(given_answer_hash, correct_answers, get_number_of_choices)

    grade_report.given_answer = {"question_id" => self.id, "answer" => given_answer_hash}

    grade_report.correct_answer = {"question_id" => self.id, "answer" => correct_answers}

    grade_report.details = get_correct_and_incorrect_text

    return grade_report
  end

  #todo: sort question grading
  #################################################################
  def question_label
    "#{self.id} - #{self.title}"
  end

  ############################
  def get_number_of_choices

    # count the number of choice elements in the question XML
    number_of_choices = self.xmlnode.xpath("//choice").count

    return number_of_choices
  end

  ############################
  def get_correct_answers
    case self.question_type

      when "single"
        answer = self.xmlnode.xpath("//choice[@score=1]")[0]["text"]
        return answer

      when "multiple"
        answer = []
        self.xmlnode.xpath("//choice[@score=1]").each do |c|
          answer << c["text"]
        end
        return answer

      when "truefalse"
        answer = {}
        true_answers    = self.xmlnode.xpath("//choice[@answer='true']")
        false_answers   = self.xmlnode.xpath("//choice[@answer='false']")

        true_answers.each do |a|
          answer[a["text"].downcase] = "true"
        end

        false_answers.each do |a|
          answer[a["text"].downcase] = "false"
        end
        return answer

      when "match"
        answer = {}

        self.xmlnode.xpath("//choice").each do |x|
          answer[x.xpath("@text").first.value.downcase] = x.xpath("@match").first.value.downcase
        end
        return answer

      when "guess"
        answers = {}

        self.xmlnode.xpath("//item").each do |item|
          answers[item['text']] = item['answer']
        end
        return answers

    end
  end
  ##################################
  def get_correct_and_incorrect_text

    help_text = {'incorrect' => {}, 'correct' => {}}
    choices   = self.xmlnode.xpath("//choice")
    choices.each do |a|
      unless a['incorrect_text'].blank? 
        help_text['incorrect'][a["text"].downcase] = a['incorrect_text']
      end
      unless a['correct_text'].blank?
        help_text['correct'][a["text"].downcase] = a['correct_text']
      end
    end
    return help_text
  end

  ##################################
  def statement
    self.xmlnode.xpath('//question/statement').first['text']
  end
  
  def choice_text
    all_text = self.xmlnode.xpath('//choice/@text')
    all_text.to_a.join(", ")
  end
  
  def choice_correct_text
    all_text = self.xmlnode.xpath('//choice/@correct_text')
    all_text.to_a.join(", ")
  end
  
  def choice_incorrect_text
    all_text = self.xmlnode.xpath('//choice/@incorrect_text')
    all_text.to_a.join(", ")
  end
  def choice_answer
    all_answer = self.xmlnode.xpath('//choice/@answer')
    all_answer.to_a.join(", ")
  end

  def choice_match
    all_match = self.xmlnode.xpath('//choice/@match')
    all_match.to_a.join(", ")
  end

  def item_text
    #and items for gridform, survey, guess
    all_item = self.xmlnode.xpath('//item/@text')
    all_item.to_a.join(", ")
  end

  def item_type
    all_item = self.xmlnode.xpath('//item/@type')
    all_item.to_a.join(", ")
  end

  def item_option_value
    all_item = self.xmlnode.xpath('//item/option/@value')
    all_item.to_a.join(", ")
  end
end
