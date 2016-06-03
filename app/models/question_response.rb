# Response for ungraded question
class QuestionResponse < QuestionResponseBase

  # Relations
  #has_paper_trail
  has_one :survey, dependent: :destroy

  # Fields
  attr_accessible :given_answer, :title

  # Validations
  validates :given_answer, presence: true

  validate :survey_required

  def survey_required
    return unless self.question.try(:question_type) == "survey"

    global = self.question.xmlnode.xpath('//question/options').first['require_all'].true?
    self.question.xmlnode.xpath('//question/item').each do |item|
      next if item['type'] == 'multi_choice'
      if (global and not item["required"].false?) || item["required"].true?
        unless self.given_answer['answer'][QuestionHelper.uniq_name_creator(item['text'])].present?
          self.errors.add :base, "Please provide a response to \"#{item['text']}\""
        end
      end
    end
  end

  # Returns answer item created by "QuestionHelper.uniq_name_creator"
  def given_answer_item(uniq_item_name)
    if given_answer['answer'].is_a? Hash
      given_answer['answer'][uniq_item_name]
    end
  end

  # Create ungraded question response
  #
  # params - must have :id_question and :given_answer
  def self.build_response_essay(user, params)
    return nil unless params[:id_question].present? && params[:given_answer].present?

    question = Question.find(params[:id_question])

    question_response = user.question_responses.by_question(question).order('updated_at DESC').first
    question_response ||= user.question_responses.build(question: question)

    # Update question
    question_response.content = question.content
    question_response.title = question.title
    question_response.question_privacy = question.org_question_privacy(user.org)

    # Update answer
    question_response.given_answer = { "answer" => params[:given_answer] }

    question_response
  end

  # Create ungraded question response
  #
  # params - must have :id_question, :answer, :item
  def self.build_response_guess(user, params)
    return nil unless params[:id_question].present? && params[:answer].present? && params[:item].present?

    question = Question.find(params[:id_question])

    question_response = user.question_responses.by_question(question).order('updated_at DESC').first
    question_response ||= user.question_responses.build(question: question)

    # Update question
    question_response.content = question.content
    question_response.title = question.title
    question_response.question_privacy = question.org_question_privacy(user.org)
    question_response.correct_answer = question.get_correct_answers

    # Update answer
    question_response.given_answer['answer'] ||= {}
    question_response.given_answer['answer'][params[:item]] = params[:answer]

    question_response
  end

  def self.build_response_survey(survey, params)
    question = survey.question
    user = survey.user

    question_response = survey.question_response
    question_response ||= QuestionResponse.new(question: question, user: user)

    # Update question
    question_response.content = question.content
    question_response.title = question.title
    question_response.question_privacy = question.org_question_privacy(user.try :org)

    # Update answer
    question_response.given_answer = { "answer" => params[:given_answer] }

    survey.question_response = question_response
    question_response
  end

  # Survey report
  def self.survey_report(params)
    opts = {}
    opts[:org_ids] = params[:org_ids] if params[:org_ids].present?

    if params[:from].present?
      if params[:from].is_a? Hash
        opts[:from] = Date.parse(params[:from].to_a.collect{|c|c[1]}.join('-')).beginning_of_day
      else
        opts[:from] = Date.parse(params[:from])
      end
    end

    if params[:to].present?
      if params[:to].is_a? Hash
        opts[:to] = Date.parse(params[:to].to_a.collect{|c|c[1]}.join('-')).end_of_day
      else
        opts[:to] = Date.parse(params[:to])
      end
    end

    ex = SurveyExtractor.new(opts)

    [ex.report_name, ex.generate_csv_report_zip]
  end

  # TODO: this should be clean_admin_results!
  def self.clean_admin_result
    User.find_each do |user|
      if user.is_admin?
        user.question_responses.destroy_all
      end
    end
  end

  # Find duplicate responses
  def self.each_duplicate(question_type)
    all = QuestionResponse.joins(:question).where('questions.question_type' => question_type)
    all.group_by {|res| [res.user_id, res.question_id] }.each do |group, responses|
      user_id, question_id = group
      if user_id && responses.count > 1
        responses.sort! {|a,b| a.updated_at <=> b.updated_at } # 1, 2, 3

        yield group, responses
      end
    end
  end

  # Fix multiple responses issue
  def self.fix_responses(question_type)
    each_duplicate(question_type) do |group, responses|
      # Newest response
      current = QuestionResponse.find(responses.last.id)

      # Convert other responses into 'paper_trail' versions
      responses.each do |res|
        unless res.id == current.id
          res.paper_trail_event = 'fix'
          res.destroy

          # Append to current's versions
          res.versions.each do |res_version|
            if res_version.object
              res_version.update_column :item_id, current.id
              if res_version.event == 'fix'
                res_version.update_column :created_at, res.updated_at
              end
            end
          end
        end
      end
    end
  end

  # Fix responses for all question types
  def self.fix_all_responses
    Question::UNGRADED_QUESTIONS.each do |question_type|
      fix_responses(question_type)
    end
  end

  # Report duplicates
  def self.report_duplicates
    all = []
    Question::UNGRADED_QUESTIONS.each do |question_type|
      each_duplicate(question_type) do |group, responses|
        #ap group
        #ap responses

        user_id, question_id = group
        all << [Question.find(question_id).question_type] + responses.map(&:id)
      end
    end

    all
  end

  # Move anonymous surveys from User to AnonymousStudent
  def self.fix_all_anonymous_surveys
    all = QuestionResponse.where("question_response_bases.user_id IS NOT NULL").by_question_type('survey').anonymous
    all.group_by {|res| res.user }.each do |user, responses|
      #pp user, responses
      anonymous_student = AnonymousStudent.create org: user.org

      responses.each do |res|
        res.update_column :user_id, nil
        res.update_column :anonymous_student_id, anonymous_student.id
      end
    end
  end

  # Move anonymous surveys from User to AnonymousStudent
  def self.fix_anonymous_surveys(user, course)
    anonymous_student = nil

    QuestionResponse.by_user(user).by_question_type('survey').by_question(course.course_questions).anonymous.each do |res|
      anonymous_student ||= AnonymousStudent.create org: user.org

      res.update_column :user_id, nil
      res.update_column :anonymous_student_id, anonymous_student.id
    end
  end

end
