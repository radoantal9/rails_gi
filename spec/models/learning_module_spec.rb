require 'spec_helper'

describe LearningModule do
  subject do
    create :learning_module, :with_lessons
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
    ap subject.lessons
    subject.lessons.count.should == 3
  end

  it 'should return lesson_by_position' do
    #pp subject.lessons
    subject.lesson_by_position(1).should == subject.lessons.first
    subject.lesson_by_position(1).should_not == subject.lesson_by_position(2)
  end

  it 'should return page_count' do
    page = 1
    subject.lessons.each do |l|
      pp "#{page} lesson #{l.inspect}"
      page += 1 # lesson text block

      l.content_pages.each do |p|
        pp "#{page}     content_page #{p.inspect}"
        page += 1 # page
      end
    end

    subject.page_count.should == 1 + 9
  end

  it 'should return course_quiz_ids' do
    c1 = create :course, :with_modules # 8 quizzes
    c2 = create :course, :with_modules # 8 quizzes
    c1.learning_modules << subject     # 4 quizzes
    c2.learning_modules << subject

    all = subject.course_quiz_ids
    #pp all
    all[:quiz_ids].count.should == 8 + 8 + 4
    all[:question_ids].count.should == 0
  end

  it 'should return own_quiz_ids' do
    all = subject.own_quiz_ids
    #pp all
    all[:quiz_ids].count.should == 4
    all[:question_ids].count.should == 0
  end

  it 'should have title' do
    course = create(:course, :with_modules)
    pp course
    pp course.learning_modules
  end
end
