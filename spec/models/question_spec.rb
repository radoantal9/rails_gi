require 'spec_helper'

describe Question do
  it 'should return content' do
    q1 = create(:question, content: QuestionXMLSamples::ESSAY)
    #q1 = build(:question, content: QuestionXMLSamples::ESSAY)
    q1.should_not be_nil
    q1.content.should == QuestionXMLSamples::ESSAY
  end

  describe "Single choice question" do
    before(:each) do
      @qs = FactoryGirl.create(:question, content: QuestionXMLSamples::SINGLE)
    end

    it "is of 'single' type" do
      # since our before_all factory object gets mangled by others
      # lets start with a fresh factory object
      @q_new = FactoryGirl.create(:question, content: QuestionXMLSamples::SINGLE)
      @q_new.question_type.should be_eql("single")
    end

    it "raises an error if content is not valid html" do
      @qs.content = "<bad>><html>"
      @qs.should be_invalid

    end

    it "saves the record if content is valid html" do
      @qs.content = QuestionXMLSamples::MULTIPLE
      @qs.should be_valid
    end

    it "has not empty content" do
      @qs.content = ""
      @qs.should be_invalid
    end

    it "has proper xmlnode after content is updated" do
      xmlstring = QuestionXMLSamples::MULTIPLE
      @qs.content = xmlstring
      @qs.xmlnode.to_s.should be_eql(Nokogiri::XML.parse(xmlstring).to_s)
    end

  end

  describe "Single choice question is graded" do
    before(:each) do
      @question = FactoryGirl.create(:question, content: QuestionXMLSamples::SINGLE)
    end

    context "with correct answer" do
      it "scores 1" do
        grade_report = @question.grade(QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS, nil, QuestionXMLSamples::QUESTION_COMMENT)
        grade_report.score.should eql(1.0)

        grade_report.score.should eql(1.0)
        grade_report.given_answer['comment']['_comment'].should_not be_empty
      end
    end

    context "with incorrect answer" do
      it "scores 0" do
        grade_report = @question.grade("Red")
        grade_report.score.should eql(0.0)
      end
    end
  end

  describe "Multiple choice question" do
    before(:each) do
      @grade_report = QuestionGradeReport.create
      @qs = FactoryGirl.create(:question, content: QuestionXMLSamples::MULTIPLE)
    end

    it "is of multiple type" do
      @qs.question_type.should be_eql("multiple")
    end

    it "gets a score of 0 if it has options not supplied by the question" do
      # The given answers are outside the scope of what was provided to the user
      @grade_report = @qs.grade(["Wendys", "McDonalds", "Burger King", "Subways", "Pizza"])
      @grade_report.score.should be_eql(0.0)
    end

    it "gets 60% score if 3 options are correct (2 explicitly and one implicitly left unchecked)" do
      # right answers are "Koala bear" and "Dogs"
      @grade_report = @qs.grade(["Dogs", "Zebras"])
      @grade_report.score.should be_eql(0.6)
    end

    it "gets a score of 0 it is choosing all the wrong options" do
      @grade_report = @qs.grade(["Chicken", "Snakes", "Crabs"])
      @grade_report.score.should be_eql(0.0)
    end
    it "gets 100% score if 2 out of 2 answers are right" do
      # right answers are "Koala bear" and "Dogs"
      @grade_report = @qs.grade(QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS)
      @grade_report.score.should be_eql(1.0)

    end

    describe "Number of choices" do
      it "are counted properly for 5 choice multiple choice question, so it can be scored properly" do
        # the multiple choice example used here has 5 choices
        q = FactoryGirl.create(:question, content: QuestionXMLSamples::MULTIPLE)
        q.get_number_of_choices.should be_eql(5)
      end
    end
  end

  describe "Graded questions" do
    it 'should create' do
      q1 = create(:question, content: QuestionXMLSamples::GUESS)
      q2 = create(:question, content: QuestionXMLSamples::GRIDFORM) #MULTIPLE_UNGRADED)
      q3 = create(:question, content: QuestionXMLSamples::SINGLE)

      Question.graded_questions.should include(q3)
      Question.graded_questions.should_not include(q1, q2)
    end
  end

  describe "Ungraded questions" do
    it 'should create' do
      q1 = create(:question, content: QuestionXMLSamples::GUESS)
      #pp q1
      q2 = create(:question, content: QuestionXMLSamples::GRIDFORM) #MULTIPLE_UNGRADED)
      q3 = create(:question, content: QuestionXMLSamples::SINGLE)

      Question.ungraded_questions.should include(q1, q2)
      Question.ungraded_questions.should_not include(q3)
    end
  end

  describe "Truefalse questions" do
    it 'get correct and incorrect text from xml' do
      q1 = create(:question, content: QuestionXMLSamples::TRUEFALSE)
      q1.question_type.should be_eql("truefalse")
      q1.get_correct_and_incorrect_text['correct'].length.should be_eql(q1.xmlnode.xpath('//choice/@correct_text').length)
      q1.get_correct_and_incorrect_text['incorrect'].length.should be_eql(q1.xmlnode.xpath('//choice/@incorrect_text').length)
    end

    context "with correct answer" do
      it "scores 1" do
        q1 = create(:question, content: QuestionXMLSamples::TRUEFALSE)

        grade_report = q1.grade(QuestionXMLSamples::TRUEFALSE_CORRECT_ANSWERS, nil, QuestionXMLSamples::TRUEFALSE_ANSWER_COMMENTS)
        ap grade_report
        #ap grade_report.given_answer

        grade_report.score.should eql(1.0)
        grade_report.given_answer['comment']['chicken are mammals'].should_not be_empty
      end

    end
  end

end
