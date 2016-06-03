require 'spec_helper'

describe SurveyExtractor do
  let(:org) { create(:org) }
  let(:org2) { create(:org) }

  let(:student) { create(:user, :student, org: org) }
  let(:student2) { create(:user, :student, org: org2) }

  let(:anon) { create(:anonymous_student, org: org) }
  let(:anon2) { create(:anonymous_student, org: org2) }

  let(:answer1) { { 'answer' => {'your_gender' => 'male'} } }
  let(:answer2) { { 'answer' => {'your_gender' => 'female'} } }

  subject do
    SurveyExtractor.new
  end

  it 'subject' do
    #pp subject
    subject.should be_a described_class
  end

  it '#report_name' do
    subject.options[:org_ids] = [org.id, org2.id]
    subject.options[:from] = 1.week.ago
    subject.options[:to] = 1.week.since
    ap subject.report_name
    subject.report_name.should include org.name
    subject.report_name.should include org2.name
  end

  describe '#question_responses' do
    let!(:q1) { create(:question, content: QuestionXMLSamples::SURVEY) }
    let!(:q2) { create(:question, content: QuestionXMLSamples::SURVEY) }

    let!(:r1) { create :question_response, user: student, question: q1, content: q1.content, given_answer: answer1 }
    let!(:r2) { create :question_response, user: student, question: q2, content: q2.content, given_answer: answer1 }

    let!(:r21) { create :question_response, user: student2, question: q1, content: q1.content, given_answer: answer1 }
    let!(:r22) { create :question_response, user: student2, question: q2, content: q2.content, given_answer: answer1 }

    let!(:r31) { create :question_response, anonymous_student: anon, question: q1, content: q1.content, given_answer: answer1 }
    let!(:r41) { create :question_response, anonymous_student: anon2, question: q1, content: q1.content, given_answer: answer1 }

    it 'for users from all orgs' do
      all = subject.question_responses_for_users(q1)
      all.should include(r1, r21)
      all.should_not include(r2, r22)
    end

    it 'for users from specific orgs' do
      subject.options[:org_ids] = [org.id]
      all = subject.question_responses_for_users(q1)
      all.to_a.should == [r1]

      subject.options[:org_ids] = [org.id, org2.id]
      all = subject.question_responses_for_users(q1)
      all.count.should == 2
      all.should include(r1, r21)
    end

    it 'for anonymous students from all orgs' do
      all = subject.question_responses_for_anonymous_students(q1)
      all.count.should == 2
      all.should include(r31, r41)
    end

    it 'for anonymous students from all orgs' do
      subject.options[:org_ids] = [org.id]
      all = subject.question_responses_for_anonymous_students(q1)
      all.count.should == 1
      all.should include(r31)
    end

    it 'for users and anonymous students' do
      all = subject.question_responses(q1)
      all.count.should == 4
      all.should include(r1, r21, r31, r41)

      subject.options[:org_ids] = [org.id]
      all = subject.question_responses(q1)
      all.count.should == 2
      all.should include(r1, r31)
    end
  end

  describe '#report_question_responses' do
    let(:q1) { create(:question, content: QuestionXMLSamples::SURVEY) }
    let(:items1) { Question.survey_items(q1.content) }

    it 'without privacy' do
      r1 = create :question_response, question_privacy: :none, user: student, question: q1, content: q1.content, given_answer: answer1
      all = subject.report_question_responses([r1], items1)
      ap all
      all.count.should == 1

      data = all[0]
      data["response_id"].should == student.id.to_s
      data["user"].should == student.full_name
      data["date"].should == r1.created_at.to_s(:date)
      data["org"].should == student.org.name
      data["anonymity"].should == "none"
      data["answers"]["Your gender"].should == "male"
      data["answers"]["Your weight"].should == nil
    end

    it 'for confidential' do
      r1 = create :question_response, question_privacy: :confidential_anonymous, user: student, question: q1, content: q1.content, given_answer: answer1
      r2 = create :question_response, question_privacy: :confidential_private, user: student, question: q1, content: q1.content, given_answer: answer1
      all = subject.report_question_responses([r1, r2], items1)
      ap all
      all.count.should == 2

      all.each do |data|
        data["response_id"].should_not == student.id.to_s
        data["user"].should == '?'
        data["org"].should == student.org.name
        %w(confidential_anonymous confidential_private).should include data["anonymity"]
      end
    end

    it 'for anonymous student' do
      r1 = create :question_response, question_privacy: :confidential_anonymous, anonymous_student: anon, question: q1, content: q1.content, given_answer: answer1
      data = subject.report_question_responses([r1], items1)[0]
      ap data

      data["response_id"].should == "anon" + anon.id.to_s
      data["user"].should == '?'
      data["date"].should == r1.created_at.to_s(:date)
      data["org"].should == anon.org.name
      data["anonymity"].should == "confidential_anonymous"
    end
  end

  it '#each_question' do
    q1 = create(:question, content: QuestionXMLSamples::SURVEY)
    q2 = create(:question, content: QuestionXMLSamples::SURVEY)
    q3 = create(:question, content: QuestionXMLSamples::ESSAY)
    expect {|b| subject.each_question(&b) }.to yield_control.exactly(2).times
  end

  describe '#each_question_reqponse_set' do
    it 'for question with single version' do
      q1 = create(:question, content: QuestionXMLSamples::SURVEY)
      r1 = create :question_response, user: student, question: q1, content: q1.content, given_answer: answer1
      r2 = create :question_response, user: student, question: q1, content: q1.content, given_answer: answer1

      count = 0
      subject.each_question_response_set do |question, question_items, question_responses|
        ap question_items

        question.should == q1
        question_items.should_not be_empty
        question_responses.sort.should == [r1, r2].sort

        count += 1
      end
      count.should == 1
    end

    it 'for question with multiple versions' do
      q1 = create(:question, content: QuestionXMLSamples::SURVEY)
      r1 = create :question_response, user: student, question: q1, content: q1.content, given_answer: answer1
      r2 = create :question_response, user: student, question: q1, content: q1.content, given_answer: answer1
      old_hash = q1.content_hash

      q1.content = q1.content.gsub(%q(<item type="number" text="Your weight"/>), '')
      q1.save!
      q1.content_hash.should_not == old_hash

      r3 = create :question_response, user: student, question: q1, content: q1.content, given_answer: answer1

      count = 0
      subject.each_question_response_set do |question, question_items, question_responses|
        ap question_items

        question.should == q1
        question_items.should_not be_empty

        if question_responses == [r3]
          question_items.should_not include "Your weight"
        else
          question_items.should include "Your weight"
          question_responses.sort.should == [r1, r2].sort
        end

        count += 1
      end
      count.should == 2
    end
  end

  describe '#generate_report' do
    let(:q1) { create(:question, content: QuestionXMLSamples::SURVEY) }

    it 'with privacy' do
      r1 = create :question_response, question_privacy: :none, user: student, question: q1, content: q1.content, given_answer: answer1
      r2 = create :question_response, question_privacy: :confidential_anonymous, user: student, question: q1, content: q1.content, given_answer: answer2
      r3 = create :question_response, question_privacy: :confidential_private, user: student, question: q1, content: q1.content, given_answer: answer1
      r4 = create :question_response, question_privacy: :confidential_anonymous, anonymous_student: anon, question: q1, content: q1.content, given_answer: answer1

      all = subject.generate_report
      ap all
      all.count.should == 1

      report = all[0]
      report[:title].should == q1.title
      report[:items].count.should == 7
      report[:data].count.should == 4

      report[:data].each do |data|
        %w(response_id user date anonymity org).each do |field|
          data[field].should_not be_empty
        end
      end

      # CSV
      all = subject.generate_csv_report
      all.count.should == 1
      all.each do |title, csv|
        pp title, csv
      end

      # ZIP
      all = subject.generate_csv_report_zip
      ap all.bytesize
      all.bytesize.should be > 400
    end

    it 'with multiple versions' do
      r1 = create :question_response, user: student, question: q1, content: q1.content, given_answer: answer1
      old_hash = q1.content_hash

      q1.content = q1.content.gsub(%q(<item type="number" text="Your weight"/>), '')
      q1.save!
      q1.content_hash.should_not == old_hash

      r2 = create :question_response, user: student, question: q1, content: q1.content, given_answer: answer2

      all = subject.generate_report
      ap all
      all.count.should == 2

      report = all[0]
      report[:title].should_not == q1.title
      report[:title].should include q1.title
      report[:items].count.should == 7
      report[:data].count.should == 1
      report[:data][0]["answers"].should == { "Your gender" => "male" }

      report = all[1]
      report[:title].should == q1.title
      report[:items].count.should == 6
      report[:data].count.should == 1
      report[:data][0]["answers"].should == { "Your gender" => "female" }

      # CSV
      all = subject.generate_csv_report
      all.count.should == 2

      i = 0
      all.each do |title, csv|
        pp title, csv
        if i == 0
          csv.should include "Your weight"
        else
          csv.should_not include "Your weight"
        end

        i += 1
      end

      # ZIP
      all = subject.generate_csv_report_zip
      ap all.bytesize
      all.bytesize.should be > 700
    end
  end
end
