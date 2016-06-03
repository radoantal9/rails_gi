require 'spec_helper'

describe InvitationJob do
  let(:inv) { create :invitation }

  subject do
    InvitationJob.new inv.id
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it '#invitation' do
    subject.invitation.should == inv
  end

  describe '#perform' do
    it 'send' do
      subject.perform
      inv = subject.invitation.reload
      inv.should be_invitation_sent
    end

    it 'accept' do
      create :user, email: inv.invitation_email

      subject.perform
      inv = subject.invitation.reload
      inv.should be_invitation_accepted
    end
  end
end
