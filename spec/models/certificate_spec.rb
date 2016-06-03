require 'spec_helper'

describe Certificate do
  let(:user) { create(:user, :student, :with_course) }
  let(:course) { user.courses.first }

  subject do
    user.id = 238066990
    Certificate.new(user, course)
  end

  it '#certificate_key' do
    key = subject.certificate_key
    ap key
    key.to_s.should include "uploads/test/certificates/"
  end

  it '#storage' do
    subject.storage.should_not be_nil

    # p subject.storage.directories
    # dir = subject.storage.directories.new(key: 'getinclusive')
    # dir.files.each do |f|
    #   p f.key
    # end

    # dir = subject.storage.directories.create(
    #   :key    => "",
    #   :public => true
    # )
    # p dir.files
  end

  # it '#certificate_file' do
  #   ap subject.certificate_file
  #   ap subject.certificate_file.body.length
  # end
  #
  # it '#certificate_url' do
  #   ap subject.certificate_url
  # end

  it '#certificate_data' do
    # pp subject.certificate_key
    pdf = subject.certificate_data(true)
    ap pdf.length
    ap user.user_detail.user_data['certificate_url']
    # ap subject.certificate_url
  end

end
