require 'spec_helper'

@params_json = {"\"quiz_id"=>"2",
                "7"=>["Turkey"],
                "1"=>["Robots"],
                "6"=>["this is yet another option"],
                "12"=>["lazy man"],
                "16"=>["Koala Bears", "Dogs", "Crabs"],
                "21"=>{"Sky is blue"=>"false",
                       "Chicken are mammals"=>"true",
                       "Wag tails the Dog"=>"true",
                       "Snakes have legs"=>"false",
                       "Pigs can swim"=>"true"},
                "15"=>["Black"],
                "17"=>["this is another option\""],
                "id"=>"2"}

describe Quiz do

  let (:quiz) {FactoryGirl.create(:quiz)}
  let (:user) {FactoryGirl.create(:user)}

  it "can have several questions of various types" do
    quiz.questions << FactoryGirl.create(:question, content: QuestionXMLSamples::SINGLE)
    quiz.questions << FactoryGirl.create(:question, content: QuestionXMLSamples::MULTIPLE)
    quiz.questions << FactoryGirl.create(:question, content: QuestionXMLSamples::TRUEFALSE)
    quiz.questions << FactoryGirl.create(:question, content: QuestionXMLSamples::MATCH)

    expect quiz.questions.count.should eql(4)
  end


  describe "when graded" do

    before (:each) do

      # Create a quiz with two questions
      @q1 = FactoryGirl.create(:question, content: QuestionXMLSamples::SINGLE)
      @q2 = FactoryGirl.create(:question, content: QuestionXMLSamples::MULTIPLE)
      quiz.questions << @q1
      quiz.questions << @q2

      # Create a params with correct answers
      @param = {}
      @param["#{@q1.id}"] = QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS
      @param["#{@q2.id}"] = QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS

      #have it graded
      #puts "Params-->#{@param}"
      @quiz_result = quiz.grade(@param)
      @quiz_result.user = user
      @quiz_result.save!

    end

    it "when scored, gets back a quiz result object" do

      @quiz_result = quiz.grade(@param).should be_an_instance_of(QuizResult)

    end

    it "has the current user associated with the quiz result object" do
      @quiz_result.user.should be_eql(user)
    end

    it "has the right number of grade reports (e.g. 2 grade reports if the quiz is two questions)" do
      #puts "QUIZ RESULT REPORT>>>"
      #@quiz_result.question_grade_reports.each do |x| puts x.inspect end

      @quiz_result.question_grade_reports.count.should be_eql(2)
    end

    it 'has a score of 100 for two correct questions' do
      @quiz_result.score.should == 100
    end

    it "saves the scores in the database" do
      QuizResult.find_by_id(@quiz_result.id).question_grade_reports.count.should be_eql(2)
    end

    it "saves the content of the question so the results are self contained" do

      qg_rpts = QuestionGradeReport.where(:quiz_result_id => @quiz_result.id)
      # We added two questions, one is single, other is multiple answer type
      qg_rpts.each do |qgr|
        if qgr.question_type.to_s == "single"
          qgr.content.should == QuestionXMLSamples::SINGLE
        end
      end
    end

  end
end
