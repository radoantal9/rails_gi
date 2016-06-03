require 'spec_helper'

describe CoursePage do
  let(:course) { create(:course, :with_simple_module) }

  subject do
    course.course_pages.first
  end

  it 'subject' do
    subject.should be_a described_class
    ap course
    # course.print_pages
    course.course_pages.count.should == 5
  end

  it '#is_learning_module?' do
    course.get_page(1).is_learning_module?.should == true
    course.get_page(2).is_learning_module?.should == false
    course.get_page(3).is_learning_module?.should == false
  end

  it '#is_content_page?' do
    course.get_page(1).is_content_page?.should == false
    course.get_page(2).is_content_page?.should == false
    course.get_page(3).is_content_page?.should == true
  end

  describe 'scope' do
    it '#by_page_type' do
      course.course_pages.by_page_type('LearningModule').pluck(:page_num).should == [1]
      course.course_pages.by_page_type('Lesson').pluck(:page_num).should == [2]
      course.course_pages.by_page_type('ContentPage').pluck(:page_num).should == [3, 4, 5]
    end

    it '#page_num_gt' do
      course.course_pages.page_num_gt(3).pluck(:page_num).should == [4, 5]
    end

    it '#page_num_lte' do
      course.course_pages.page_num_lte(3).pluck(:page_num).should == [1, 2, 3]
    end
  end

  describe '#can_rate_lesson?' do
    it 'good' do
      current_page = course.get_page(5)
      current_lesson = current_page.lesson
      current_lesson.update_attributes rate_lesson: true
      next_lesson = nil
      current_page.can_rate_lesson?(next_lesson).should == true
    end

    it 'bad' do
      current_page = course.get_page(4)
      current_lesson = current_page.lesson
      current_lesson.update_attributes rate_lesson: true
      next_lesson = current_lesson
      current_page.can_rate_lesson?(next_lesson).should == false
    end
  end

  describe '#has_user_responses?' do
    let(:learning_module1) { course.learning_module_by_position(1) }
    let(:lesson1) { learning_module1.lesson_by_position(1) }
    let(:content_page11) { lesson1.content_page_by_position(1) }

    it 'question' do
      # course.print_pages

      q1 = create :question, content: QuestionXMLSamples::ESSAY
      content_page11.content_page_elements.destroy_all
      content_page11.reload
      content_page11.add_element(q1)

      course.generate_course_pages
      page = course.get_page(3)
      ap page

      u1 = create :user, :student
      page.has_user_responses?(u1).should == false

      r1 = create :question_response, user: u1, question: q1, content: q1.content, given_answer: { 1 => 2 }
      page.has_user_responses?(u1).should == true
    end

    it 'quiz' do
      quiz = create :quiz
      q1 = create :question, content: QuestionXMLSamples::ESSAY
      quiz.questions << q1
      content_page11.content_page_elements.destroy_all
      content_page11.add_element(quiz)

      course.generate_course_pages
      page = course.get_page(3)
      ap page

      u1 = create :user, :student
      page.has_user_responses?(u1).should == false

      quiz_result = create :quiz_result, user: u1, quiz: quiz
      r1 = create :question_grade_report, user: u1, quiz_result: quiz_result, question: q1, content: q1.content, given_answer: { 1 => 2 }
      page.has_user_responses?(u1).should == true
    end
  end
end
