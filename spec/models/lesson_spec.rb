require 'spec_helper'

describe Lesson do
  subject do
    create :lesson, :with_pages
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
    ap subject.content_pages
    subject.content_pages.count.should == 3
  end

  it 'should add content_pages' do
    lesson = create :lesson
    lesson.content_pages.should be_empty
    lesson.content_pages << create(:content_page)
    lesson.content_pages.count.should == 1
  end

  it 'should order' do
    lesson_content_pages_join = ContentPagesLesson.where(lesson_id: subject)
    #pp lesson_content_pages_join

    #pp subject.content_pages.order("position")
  end

  it 'should return content_page_by_position' do
    # position: nil
    lesson_content_pages_join = ContentPagesLesson.where(lesson_id: subject)
    #pp lesson_content_pages_join

    #pp subject.content_pages

    subject.content_page_by_position(1).should == subject.content_pages.first

    #pp subject.content_page_by_position(1)
    #pp subject.content_page_by_position(2)
    #pp subject.content_page_by_position(3)
  end

  it 'should return page_count' do
    page = 1
    subject.content_pages.each do |p|
      pp "#{page} content_page #{p.inspect}"
      page += 1 # page
    end

    subject.page_count.should == 1 + 3
  end

  it 'should return course_quiz_ids' do
    c1 = create :course, :with_modules # 8 quizzes
    c2 = create :course, :with_modules # 8 quizzes
    c1.learning_modules.first.lessons << subject # 2 quizzes
    c2.learning_modules.first.lessons << subject

    all = subject.course_quiz_ids
    #pp all
    all[:quiz_ids].count.should == 8 + 8 + 2
    all[:question_ids].count.should == 0
  end

  it 'should return own_quiz_ids' do
    all = subject.own_quiz_ids
    #pp all
    all[:quiz_ids].count.should == 2
    all[:question_ids].count.should == 0
  end

  it 'should return quizzes' do
    subject.quizzes.count.should == 2
  end
end
