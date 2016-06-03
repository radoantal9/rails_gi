require 'spec_helper'

describe QuestionResponse do
  let (:user) { FactoryGirl.create(:user) }
  let (:admin) { FactoryGirl.create(:user, :admin) }

  before(:each) do
    @q1 = FactoryGirl.create(:question,
                             content: QuestionXMLSamples::SINGLE)
    @q1_response = FactoryGirl.create(:question_response,
                                      content: QuestionXMLSamples::SINGLE,
                                      given_answer: { "answer" => "answer" })
    @q1_response.user = user
  end

  it "belongs to a user" do
    @q1_response.user.should be_eql(user)
  end

  it "should be have content" do
    @q1_response.content.should be_eql(QuestionXMLSamples::SINGLE)
  end

  it "should be have given_answer of Hash" do
    @q1_response.given_answer.should be_kind_of(Hash)
  end

  it "should not be valid nill content and given_answer" do
    @q1_response.content = ""
    @q1_response.should be_invalid
    @q1_response.content = QuestionXMLSamples::SINGLE
    @q1_response.should be_valid

    @q1_response.given_answer = {}
    @q1_response.should be_invalid
  end

  it "raises an error if content is not valid html" do
    @q1_response.content = "<bad>><html>"
    @q1_response.should be_invalid

  end

  it "saves the record if content is valid html" do
    @q1_response.given_answer = { "answer" => "answer" }
    @q1_response.content = "<good name='awesome'>html</good>"
    @q1_response.should be_valid
  end

  it "has proper xmlnode after content is updated" do
    @q1_response.given_answer = { "answer" => "answer" }
    xmlstring = "<element>joy</element>"
    @q1_response.content = xmlstring
    @q1_response.xmlnode.to_s.should be_eql(Nokogiri::XML.parse(xmlstring).to_s)
  end

  it "has method clean_admin_result" do
    @q2_response = FactoryGirl.create(:question_response,
                                      user: admin,
                                      content: QuestionXMLSamples::SINGLE,
                                      given_answer: { "answer" => "answer" })
    @q3_response = FactoryGirl.create(:question_response,
                                      user: admin,
                                      content: QuestionXMLSamples::SINGLE,
                                      given_answer: { "answer" => "answer" })
    @q4_response = FactoryGirl.create(:question_response,
                                      user: user,
                                      content: QuestionXMLSamples::SINGLE,
                                      given_answer: { "answer" => "answer" })
    QuestionResponse.all.length.should be_eql(4)
    QuestionResponse.clean_admin_result
    QuestionResponse.all.length.should be_eql(2)
    QuestionResponse.all.should include(@q4_response, @q1_response)
  end

  describe "QuestionResponse fix" do
    let(:student) { FactoryGirl.create(:user, :student) }
    let(:question) { create(:question, content: QuestionXMLSamples::GUESS) }

    subject do
      create :question_response, user: student, question: question,
             content: question.content,
             given_answer: {
               'answer' => { 'k1' => 'v1' }
             }
    end

    before(:all) do
      @was_enabled = PaperTrail.enabled?
      PaperTrail.enabled = true
    end

    after(:all) do
      PaperTrail.enabled = @was_enabled
    end

    it 'has_paper_trail' do
      pending
      PaperTrail.should be_enabled

      #ap subject
      subject.versions.count.should == 1

      subject.given_answer = { 'answer' => { 'k2' => 'v2' } }
      subject.save!

      subject.versions.count.should == 2

      subject.given_answer = { 'answer' => { 'k2' => 'v2' } }
      subject.save!

      subject.versions.count.should == 2
    end

    it 'versions' do
      pending
      res1 = create :question_response, user: student, question: question, updated_at: 1.day.ago,
                    content: question.content,
                    given_answer: {
                      'answer' => {
                        'k1' => 'v1',
                        'k2' => 'v2'
                      }
                    }
      #ap res1

      res2 = create :question_response, id: res1.id + 1, user: student, question: question, updated_at: Time.now, # newest
                    content: question.content,
                    given_answer: {
                      'answer' => {
                        'k1' => 'v11',
                        'k2' => 'v22'
                      }
                    }
      #ap res2
      res2.versions.count.should == 1

      res3 = create :question_response, id: res1.id + 2, user: student, question: question, updated_at: 2.day.ago,
                    content: question.content,
                    given_answer: {
                      'answer' => {
                        'k1' => 'v11',
                        'k3' => 'v3'
                      }
                    }
      #ap res3

      question.question_responses.count.should == 3

      ap QuestionResponse.report_duplicates

      QuestionResponse.fix_responses('guess')

      question.question_responses.count.should == 1
      question.question_responses.first.should == res2 # newest

      versions = res2.versions
      #ap versions
      versions.count.should == 3

      versions[0].object.should include 'k3: v3'
      versions[1].object.should include 'k1: v1'
      versions[2].object.should == nil
    end

    it 'all anonymous surveys' do
      q1 = create(:question, content: QuestionXMLSamples::SURVEY)

      res1 = create :question_response, question_privacy: :confidential_anonymous, user: student, question: q1, content: q1.content, given_answer: { 'answer' => {} }
      QuestionResponse.by_question_type('survey').anonymous.should include res1

      QuestionResponse.fix_all_anonymous_surveys

      res1.reload

      res1.user.should == nil
      res1.anonymous_student.should_not == nil
    end

    it 'user anonymous surveys' do
      c1 = create(:course, :with_simple_module)
      q1 = create(:question, content: QuestionXMLSamples::SURVEY)
      q2 = create(:question, content: QuestionXMLSamples::SURVEY)

      c1.learning_modules.first.lessons.first.content_pages.first.add_element(q1)
      c1.set_course_pages_changed(true)
      c1.course_questions.should include(q1)

      res1 = create :question_response, question_privacy: :confidential_anonymous, user: student, question: q1, content: q1.content, given_answer: { 'answer' => {} }
      res2 = create :question_response, question_privacy: :confidential_private, user: student, question: q1, content: q1.content, given_answer: { 'answer' => {} }
      res3 = create :question_response, question_privacy: :confidential_private, user: student, question: q2, content: q2.content, given_answer: { 'answer' => {} }
      QuestionResponse.by_question_type('survey').anonymous.should include res1

      student2 = create(:user, :student)
      res21 = create :question_response, question_privacy: :confidential_anonymous, user: student2, question: q1, content: q1.content, given_answer: { 'answer' => {} }

      QuestionResponse.fix_anonymous_surveys(student, c1)

      res1.reload

      res1.user.should == nil
      res1.anonymous_student.should_not == nil

      res2.user.should_not == nil
      res3.user.should_not == nil
      res21.user.should_not == nil

      AnonymousStudent.count.should == 1
    end
  end

  it '.build_response_guess' do
    q1 = create(:question, content: QuestionXMLSamples::GUESS)
    params = { "id_question" => q1.id, "answer" => "50", "item" => "% of students studying engineering in the US" }.with_indifferent_access
    r1 = QuestionResponse.build_response_guess(user, params)
    ap r1
    r1.save.should == true
    ap r1.reload
  end
end
