require 'spec_helper'

describe ContentStorage do
  subject do
    ContentStorage
  end

  it '.by_hash' do
    c1 = create :content_storage
    c2 = create :content_storage

    subject.by_hash(c1.content_hash).should == c1
    subject.by_content(c2.content_data).should == c2
  end

  it '.add_content' do
    c1 = create :content_storage
    c2 = create :content_storage
    subject.count.should == 2

    new_content = 'asjhdkjasjkd'
    subject.add_content(new_content).should == subject.generate_hash(new_content)
    subject.count.should == 3

    # same
    subject.add_content(c1.content_data).should == c1.content_hash
    subject.count.should == 3
  end

end
