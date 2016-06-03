require 'spec_helper'

describe TextBlock do
  subject do
    create :text_block
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it 'should scope for_content_pages' do
    tb1 = create :text_block
    tb2 = create :text_block
    l1 = create :lesson, text_block: tb2
    tb2.reload
    #pp tb2

    TextBlock.for_content_pages.should include tb1
    TextBlock.for_content_pages.should_not include tb2
  end

  it 'should scope for_courses' do
    tb1 = create :text_block
    tb2 = create :text_block
    l1 = create :lesson, text_block: tb2

    TextBlock.for_courses.should_not include tb1
    TextBlock.for_courses.should include tb2
  end
end
