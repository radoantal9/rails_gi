require 'spec_helper'

describe Invitation do
  subject do
    create :invitation
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  context 'invitation_state' do
    it 'send_invitation' do
      subject.sent_at.should == nil
      subject.send_invitation
      subject.reload
      subject.invitation_state.should == 'invitation_sent'
      subject.sent_at.should be_a Time
    end

    it 'accept_invitation' do
      subject.invited_user = create :user, :student, org: subject.orgs_course.org
      subject.invited_user.users_courses.create! course: subject.orgs_course.course
      subject.invited_user.reload

      subject.invitation_state.should_not == 'invitation_accepted'

      subject.accept_invitation
      subject.reload
      subject.invitation_state.should == 'invitation_accepted'

      subject.accept_invitation
      subject.invitation_accepted?.should == true
    end

    it 'after_transition' do
      user_events = UserEvent.by_email(subject.invitation_email)
      user_events.should be_empty

      subject.send_invitation
      user_events.reload
      user_events.count.should == 1
      user_events.first.should be_invitation_sent

      subject.reset_invitation
      subject.send_invitation
      user_events.reload
      user_events.count.should == 2
      user_events.first.should be_invitation_sent

      subject.view_invitation
      user_events.reload
      user_events.count.should == 3
      user_events.first.should be_invitation_viewed

      subject.invited_user = create :user, :student, org: subject.orgs_course.org
      subject.invited_user.users_courses.create! course: subject.orgs_course.course
      subject.invited_user.reload

      subject.accept_invitation
      user_events.reload
      user_events.count.should == 4
      user_events.first.should be_invitation_accepted
    end
  end

  context 'scope' do
    it 'accepted' do
      inv1 = create :invitation
      inv2 = create :invitation, invitation_state: :invitation_accepted

      Invitation.accepted.should include(inv2)
      Invitation.accepted.should_not include(inv1)
      Invitation.not_accepted.should include(inv1)
      Invitation.not_accepted.should_not include(inv2)
    end

    it 'by_token' do
      inv1 = create :invitation
      inv2 = create :invitation
      Invitation.by_token(inv1.invitation_token).should include(inv1)
      Invitation.by_token(inv1.invitation_token).should_not include(inv2)
    end
  end

  it '.normalize_attributes' do
    subject.invitation_email.upcase!
    subject.save
    subject.reload
    subject.invitation_email.should == subject.invitation_email.downcase
  end

  it '.find_or_create_invitation' do
    orgs_course = create :orgs_course
    email = FFaker::Internet.email

    # create
    inv = Invitation.find_or_create_invitation(orgs_course.org, orgs_course.course, email)
    inv.should be_invitation_created

    # find
    inv2 = Invitation.find_or_create_invitation(orgs_course.org, orgs_course.course, email)
    inv2.should == inv
    inv2.should be_invitation_created
  end

  it '.create_invitations' do
    o1 = create :org
    c1 = create(:course)
    u1 = create(:user, :student, org: o1)
    u2 = create(:user, :student, org: o1)
    create :orgs_course, org: o1, course: c1
    create :users_course, user: u1, course: c1

    e1 = FFaker::Internet.email
    e2 = FFaker::Internet.email
    bad1 = 'bad_mail'
    emails = [e1, bad1, e2, u1.email, u2.email]

    res = Invitation.create_invitations(o1, c1, emails.join("\n"))
    ap res
    res[:invited].should match_array [e1, e2]
    res[:error].should match_array [bad1]
    res[:ignored].should match_array [u1.email]
    res[:enrolled].should match_array [u2.email]

    Invitation.where(invitation_email: e1).should be_exist
    Invitation.where(invitation_email: e2).should be_exist
  end
  
  it '.update_invitation_state' do
    Invitation.update_invitation_state subject.invitation_email
    subject.reload
    subject.invitation_state.should_not == 'invitation_accepted'

    user = create :user, email: subject.invitation_email

    Invitation.update_invitation_state subject.invitation_email
    subject.reload
    subject.invitation_state.should == 'invitation_accepted'
    subject.invited_user.should == user
  end

  it '.resend_invitations' do
    c1 = create :course
    o1 = create :org
    create :orgs_course, org: o1, course: c1

    e1 = FFaker::Internet.email
    e2 = FFaker::Internet.email
    e3 = FFaker::Internet.email
    e4 = FFaker::Internet.email
    res = Invitation.create_invitations(o1, c1, [e1, e2, e3, e4].join("\n"))
    ap res

    i1 = Invitation.by_email(e1).first
    i2 = Invitation.by_email(e2).first
    i3 = Invitation.by_email(e3).first
    i4 = Invitation.by_email(e4).first

    i2.invited_user = create :user, :student, org: i2.orgs_course.org
    i2.invited_user.users_courses.create! course: i2.orgs_course.course
    i2.invited_user.reload
    i2.accept_invitation   # skip

    i3.view_invitation
    i4.fail_invitation
    i1.should be_invitation_sent
    i2.should be_invitation_accepted
    i3.should be_invitation_viewed
    i4.should be_invitation_failed

    res = Invitation.resend_invitations(o1, c1)
    ap res
    res[:resend].should match_array [e1, e3, e4]
    i1.reload.should be_invitation_sent
    i3.reload.should be_invitation_sent
    i4.reload.should be_invitation_sent
  end
end
