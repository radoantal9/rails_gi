# Base class for graded/ungraded question response
class QuestionResponseBase < ActiveRecord::Base
  # Relations
  belongs_to :user
  belongs_to :anonymous_student
  belongs_to :question

  # Fields
  as_enum :question_privacy, Question::QUESTION_PRIVACY, slim: false
  attr_accessible :content, :question_privacy, :question, :question_id, :user, :user_id, :anonymous_student, :correct_answer

  serialize :correct_answer, Hash # Correct answers
  serialize :given_answer, Hash   # What answer(s) were given by the user
  serialize :details, Hash        # Correct answers for each option for display to user

  # Validations
  validates :content, :content_hash, presence: true
  validate :validate_html_in_content

  # Scopes
  scope :by_user, ->(user) { where(user_id: user) }
  scope :by_question, ->(question) { where(question_id: question) }
  scope :by_question_type, ->(question_type) { joins(:question).where('questions.question_type' => question_type) }
  scope :not_private, -> { where("question_response_bases.question_privacy_cd != ?", Question.confidential_private) }
  scope :anonymous, -> { where("question_response_bases.question_privacy_cd = ?", Question.confidential_anonymous) }

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

  def validate_html_in_content
    # if we have errors, thats an issue
    errs = Nokogiri::XML.parse(self.content).errors
    if errs.count > 0
      errtxt = errs.join(';')
      errors.add(:content, "Invalid HTML #{errs.count} errors; #{errtxt}")
    end
  end

  # Parsed content
  def xmlnode
    @xmlnode ||= Nokogiri::XML.parse(self.content)
  end

  def get_given_answer
    self.given_answer["answer"]
  end

  def statement
    self.xmlnode.xpath('//question/statement').first['text']
  end

  def choice_text
    all_text = self.xmlnode.xpath('//choice/@text')
    all_text.to_a.join(", ")
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

  def question_type
    self.xmlnode.xpath('//options/@type')[0].value
  end

  def answer_for_report
    answer = get_given_answer
    unless answer.is_a? String
      answer = answer.inspect
    end
    answer
  end
end
