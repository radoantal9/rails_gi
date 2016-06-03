require 'spec_helper'

describe CourseQuizValidator do
  let(:course) { create :course, :with_simple_module }
  let(:learning_module1) { course.learning_module_by_position(1) }
  let(:lesson1) { learning_module1.lesson_by_position(1) }
  let(:content_page1) { lesson1.content_page_by_position(1) }
  let(:content_page2) { lesson1.content_page_by_position(2) }
  let(:content_page3) { lesson1.content_page_by_position(3) }

  let(:quiz1) { content_page1.quizzes.first }
  let(:quiz2) { create(:quiz) }
  
  let(:page_with_quiz1) do
    page = create :content_page, name: 'page_with_quiz1'
    page.add_element(quiz1)
    page
  end

  let(:lesson_with_quiz1) do
    lesson = create :lesson
    lesson.content_pages << page_with_quiz1
    lesson
  end

  let(:learning_module_with_quiz1) do
    learning_module = create :learning_module
    learning_module.lessons << lesson_with_quiz1
    learning_module
  end

  before :each do
    content_page1.add_element(quiz1)
  end

  it 'should not add quiz to content_page' do
    content_page1.add_element(quiz2)
    content_page1.quizzes.count.should == 2

    content_page1.add_element(quiz2)
    content_page1.quizzes.count.should == 2
  end

  it 'should not add content_page to lesson' do
    pp lesson1.content_pages
    expect {
      lesson1.content_pages << page_with_quiz1
    }.to raise_error /quiz/

    page_with_quiz2 = create :content_page
    page_with_quiz2.add_element(quiz2)

    lesson1.content_pages << page_with_quiz2
    lesson1.content_pages.count.should == 4
  end

  it 'should not add lesson to learning_module' do
    expect {
      learning_module1.lessons << lesson_with_quiz1
    }.to raise_error /quiz/
  end

  it 'should not add learning_module to course' do
    expect {
      course.learning_modules << learning_module_with_quiz1
    }.to raise_error /quiz/
  end

end
