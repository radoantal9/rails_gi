require 'csv'
require 'zip'

class SurveyExtractor
  attr_accessor :options

  def initialize(options = {})
    @options = options
  end

  def report_name
    name = []
    name << "Survey report"
    if options[:org_ids].present?
      name << "for"
      name << Org.where(id: options[:org_ids]).pluck(:name).join(', ')
    end

    if options[:from]
      name << "from #{options[:from].to_date.to_s(:db)}"
    end

    if options[:to]
      name << "to #{options[:to].to_date.to_s(:db)}"
    end

    name.join ' '
  end
  
  # For users from "options[:org_ids]"
  def question_responses_for_users(question)
    query = question.question_responses.joins(user: :org)
    query = query.where('orgs.id' => options[:org_ids]) if options[:org_ids].present?
    query = query.where('question_response_bases.created_at >= ?', options[:from]) if options.has_key? :from
    query = query.where('question_response_bases.created_at <= ?', options[:to]) if options.has_key? :to

    query
  end

  # For anonymous_students from "options[:org_ids]"
  def question_responses_for_anonymous_students(question)
    query = question.question_responses.joins(anonymous_student: :org)
    query = query.where('orgs.id' => options[:org_ids]) if options[:org_ids].present?
    query = query.where('question_response_bases.created_at >= ?', options[:from]) if options.has_key? :from
    query = query.where('question_response_bases.created_at <= ?', options[:to]) if options.has_key? :to

    query
  end

  # Question responses from all users
  def question_responses(question)
    query1 = question_responses_for_users(question).to_sql.sub('$1', question.to_param)
    query2 = question_responses_for_anonymous_students(question).to_sql.sub('$1', question.to_param)
    QuestionResponse.from("(#{query1} UNION #{query2}) AS question_response_bases")
  end

  # Report question_responses for specific set of 'question_items'
  def report_question_responses(question_responses, question_items)
    report = []

    question_responses.each do |qr|
      data = {}

      # User data
      if qr.question_privacy == :none && qr.user
        data['response_id'] = qr.user_id.to_s
        data['user'] = qr.user.full_name
      else
        if qr.user
          data['response_id'] = uniq_id(qr.user)
        elsif qr.anonymous_student
          data['response_id'] = "anon#{qr.anonymous_student.id}"
        end
        data['user'] = "?"
      end

      data['date'] = qr.created_at.to_s(:date)
      data['anonymity'] = qr.question_privacy.to_s

      if qr.user
        data['org'] = qr.user.org.name
      elsif qr.anonymous_student
        data['org'] = qr.anonymous_student.org.name
      end

      # Answers
      data['answers'] = {}
      question_items.each do |item|
        answer = qr.given_answer_item QuestionHelper.uniq_name_creator(item)
        if answer.is_a? Array
          answer = answer.join(', ')
        end

        answer = answer.to_s
        if answer.present?
          data['answers'][item] = answer
        end
      end

      # Skip empty
      unless data['answers'].empty?
        report << data
      end
    end

    report
  end

  # Iterate questions
  def each_question(&block)
    Question.ungraded_questions.by_question_type(:survey).each(&block)
  end

  # Iterate question responses grouped by question content version
  def each_question_response_set
    each_question do |question|
      question_responses(question).group_by(&:content_hash).each do |content_hash, question_responses|
        content = ContentStorage.by_hash(content_hash)

        question_items = Question.survey_items(content.try(:content_data))
        next if question_items.empty?

        yield question, question_items, question_responses, content_hash
      end
    end
  end

  # Generate reports for each question/question version
  def generate_report
    pages = []
    each_question_response_set do |question, question_items, question_responses, content_hash|
      title = question.title
      title += " #{content_hash}" if question.content_hash != content_hash

      report = report_question_responses(question_responses, question_items)
      unless report.empty?
        pages << {
          title: title,
          items: question_items,
          data: report
        }
      end
    end

    pages
  end

  # Reports in CSV format
  def generate_csv_report
    base = %w(response_id user date anonymity org)
    csv_pages = {}
    generate_report.each do |page|
      csv_pages[page[:title]] = CSV.generate do |csv|
        # Header
        csv << base + page[:items]

        page[:data].each do |data|
          base_data = base.map {|attr| data[attr] }
          answers_data = page[:items].map {|attr| data['answers'][attr] }

          csv << base_data + answers_data
        end
      end
    end

    csv_pages
  end

  # Pack CSV files
  def generate_csv_report_zip
    zip_file = Zip::OutputStream::write_buffer do |zio|
      generate_csv_report.each do |title, csv|
        zio.put_next_entry "#{title}.csv"
        zio.write csv
      end
    end

    zip_file.rewind
    zip_file.sysread
  end

  private

  def uniq_id(user)
    @offset ||= rand(99999)
    bbs = ((user.id + @offset) ** 2) % (32416190071 * 32416189381)
    Digest::MD5.hexdigest user.full_name + bbs.to_s
  end
end
