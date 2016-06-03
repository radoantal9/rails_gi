require 'spec_helper'

describe ContentPage do
  subject do
    create :content_page, :with_elements
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
    subject.content_page_elements.count.should == 3
  end

  it 'should add_element' do
    page = create :content_page
    page.content_page_elements.count.should == 0
    page.add_element create(:text_block)
    page.add_element create(:quiz)
    page.content_page_elements.count.should == 2
  end

  it 'should order by position' do
    #pp subject.content_page_elements
    subject.content_page_elements.first.position.should == 1
  end

  it 'should iterate each element' do
    subject.content_page_elements.each do |pos|
      #pp pos.element
    end
  end

  it 'should work with elements' do
    #ContentPage has_many :elements, through: :content_page_elements
    #pp subject.elements

    el = subject.content_page_elements.first.element
    el.content_pages.should include subject
  end

  it 'should sort_elements' do
    pos_ids = subject.content_page_elements.pluck(:id)
    #pp pos_ids

    rev_pos_ids = pos_ids.reverse
    subject.sort_elements(rev_pos_ids)

    subject.content_page_elements.pluck(:id).should == rev_pos_ids
    #pp rev_pos_ids
  end

  it 'should destroy element' do
    page = create :content_page
    page.content_page_elements.count.should == 0
    text1 = create(:text_block)
    page.add_element text1
    quiz1 = create(:quiz)
    page.add_element quiz1
    page.content_page_elements.count.should == 2

    text1.destroy
    quiz1.destroy

    page.content_page_elements.count.should == 0
  end

  it 'should get quizzes' do
    #pp subject.quizzes
    subject.quizzes.count.should == 1
  end

  it 'should get text_blocks' do
    #pp subject.text_blocks
    subject.text_blocks.count.should == 2
  end

  it 'should add ungraded questions' do
    q1 = create(:question, content: QuestionXMLSamples::GUESS)
    #pp q1

    subject.add_element(q1).should == true

    # added
    subject.ungraded_questions.should include(q1)
    q1.content_pages.should include(subject)

    # skip already added
    subject.add_element(q1).should == false
  end

  it 'should return course_quiz_ids' do
    c1 = create :course, :with_modules # 8 quizzes
    c2 = create :course, :with_modules # 8 quizzes
    c1.learning_modules.first.lessons.first.content_pages << subject # 1 quiz
    c2.learning_modules.first.lessons.first.content_pages << subject

    all = subject.course_quiz_ids
    #pp all
    all[:quiz_ids].count.should == 8 + 8 + 1
    all[:question_ids].count.should == 0
  end

  it 'should return own_quiz_ids' do
    all = subject.own_quiz_ids
    #pp all
    all[:quiz_ids].count.should == 1
    all[:question_ids].count.should == 0
  end

end
