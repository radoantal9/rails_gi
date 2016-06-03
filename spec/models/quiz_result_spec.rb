require 'spec_helper'

describe QuizResult do
  subject (:quiz_result) { QuizResult.new }

  describe "when it has two question grade reports in it" do
    before(:each) do
      @q1 = FactoryGirl.create(:question, content: QuestionXMLSamples::SINGLE)
      @q2 = FactoryGirl.create(:question, content: QuestionXMLSamples::MULTIPLE)

      @qgr_1 = @q1.grade(QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS)
      @qgr_2 = @q2.grade(QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS)

      @user = FactoryGirl.create(:user)

      quiz_result.user = @user
      @qgr_1.score.should be_eql(1.0)
      @qgr_2.score.should be_eql(1.0)

      quiz_result.save!
    end

    it "belongs to a user" do
      quiz_result.user.should be_eql(@user)
    end

    it "reports that it has 2 grade reports" do
      quiz_result.question_grade_reports << @qgr_1
      quiz_result.question_grade_reports << @qgr_2
      quiz_result.question_grade_reports.count.should == 2
    end

    it "should be valid" do
      quiz_result.question_grade_reports << @qgr_1
      quiz_result.question_grade_reports << @qgr_2

      quiz_result.should be_valid
    end

    it "should be saved in the database" do
      quiz_result.question_grade_reports << @qgr_1
      quiz_result.question_grade_reports << @qgr_2

      quiz_result.errors.count.should == 0
    end

    it "deletes all dependent question grade reports when deleted" do
      quiz_result.question_grade_reports << @qgr_1

      #puts "Record Before:" + QuestionGradeReport.find_by_id(@qgr_1.id).inspect
      expect(QuestionGradeReport.find_by_id(@qgr_1.id)).to_not be_nil
      quiz_result.destroy

      #puts "Exists After:" + QuestionGradeReport.exists?(id: @qgr_1.id).to_s
      QuestionGradeReport.exists?(id: @qgr_1.id).should be_false
    end

  #################### SCORING #########################

    it "has a score of 1.0 if all the answers are correct" do
      #quiz_result.question_grade_reports.each do |q| puts q.inspect end
      quiz_result.question_grade_reports << @q1.grade(QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS)
      quiz_result.question_grade_reports << @q2.grade(QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS)

      #quiz_result.question_grade_reports.each do |q| puts "AFTER>>" + q.inspect end

      quiz_result.score.should == 100
    end

    it "has a score of 0 if all answers are incorrect" do
      quiz_result.question_grade_reports << @q1.grade("Banana")

      # the incorrect options for the multiple choice question
      quiz_result.question_grade_reports << @q2.grade(["Chicken", "Snakes", "Crabs"])

      quiz_result.score.should == 0
    end

    it "has a score of 50 if one out of two answere are correct" do
      quiz_result.question_grade_reports << @q1.grade("Banana")
      quiz_result.question_grade_reports << @q2.grade(QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS)
      quiz_result.score.should == 50
    end

    it "has a score of 80 if one answer is correct (50) and 3/5th of the multiple is correct (30)" do
      quiz_result.question_grade_reports << @q1.grade(QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS)
      quiz_result.question_grade_reports << @q2.grade(["Dogs", "Wrong"])
      quiz_result.score.should == 80
    end

    it '#write_score add' do
      quiz_result.should_not receive(:score)

      pp 'add'
      quiz_result.question_grade_reports << @q1.grade(QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS)
      quiz_result.question_grade_reports << @q2.grade(QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS)

      pp 'read'
      quiz_result.write_score
      quiz_result.read_score.should == 100

      pp 'remove1'
      # 'after_remove' callback not called
      quiz_result.question_grade_reports.first.destroy

      pp 'remove2'
      # call 'after_remove' callback
      quiz_result.question_grade_reports.delete(quiz_result.question_grade_reports.first)

      pp 'done'
    end
  end

  it '#write_score new' do
    @q1 = FactoryGirl.create(:question, content: QuestionXMLSamples::SINGLE)
    res = QuizResult.new

    res.question_grade_reports << @q1.grade(QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS)
    res.save!

    res.reload
    res.read_score.should == 100
  end

  describe "has method clean admin resutl" do
    it "clean all admin's result" do
      @q1 = FactoryGirl.create(:question, content: QuestionXMLSamples::SINGLE)
      @q2 = FactoryGirl.create(:question, content: QuestionXMLSamples::MULTIPLE)

      @qgr_1 = @q1.grade(QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS)
      @qgr_2 = @q2.grade(QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS)

      quiz_result.question_grade_reports << @qgr_1
      quiz_result.question_grade_reports << @qgr_2

      user = FactoryGirl.create(:user)

      quiz_result.user = user
      quiz_result.save!

      quiz_result_admin = QuizResult.new
      admin = FactoryGirl.create(:user, :admin)
      quiz_result_admin.user = admin

      @qgr_1 = @q1.grade(QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS)
      @qgr_2 = @q2.grade(QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS)

      quiz_result_admin.question_grade_reports << @qgr_1
      quiz_result_admin.question_grade_reports << @qgr_2

      quiz_result_admin.save!

      QuizResult.all.length.should be_eql(2)
      QuestionGradeReport.all.length.should be_eql(4)
      QuizResult.clean_admin_result
      QuizResult.all.length.should be_eql(1)
      QuestionGradeReport.all.length.should be_eql(2)
    end
  end
end
