require 'spec_helper'

describe Reminder do
  subject do
    create :reminder
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  describe 'reminder_state' do
    it 'event' do
      subject.view_reminder
      subject.reload.should be_reminder_viewed

      subject.send_reminder
      subject.reload.should be_reminder_viewed
      subject.sent_at.should be_nil
      subject.sent_count.should == 0

      subject.reset_reminder
      subject.reload.should be_reminder_created

      subject.send_reminder
      subject.reload.should be_reminder_sent
      subject.sent_at.should be_a Time
      subject.sent_count.should == 1
    end

    it 'after_transition' do
      user = subject.user
      user.user_events.should be_empty

      subject.send_reminder
      user.reload
      user.user_events.count.should == 1
      user.user_events.first.should be_reminder_sent

      subject.reset_reminder
      subject.send_reminder
      user.reload
      user.user_events.count.should == 2
      user.user_events.first.should be_reminder_sent

      subject.view_reminder
      user.reload
      user.user_events.count.should == 3
      user.user_events.first.should be_reminder_viewed

      subject.accept_reminder
      user.reload
      user.user_events.count.should == 4
      user.user_events.first.should be_reminder_accepted

      ap user.user_events
    end
  end

  it '.create_reminders' do
    o1 = create :org
    c1 = create :course
    expect { Reminder.create_reminders(o1, c1, []) }.to raise_error

    create :orgs_course, org: o1, course: c1
    u1 = create :user, :student, org: o1
    u1.courses << c1
    u2 = create :user, :student, org: o1
    u2.courses << c1
    u3 = create :user, :student, org: o1
    u3.courses << c1
    u4 = create :user, :student, org: o1

    c1.user_events.create! user: u3, event_type: 'course_end'

    # selected
    res = Reminder.create_reminders(o1, c1, [u1.id, u2.id, u3.id, u4.id])
    ap res
    res[:created].should == [u1.id, u2.id]
    res[:ignored].should == [u3.id]
    res[:resent].should be_empty
    res[:error].should == [u4.id]

    res = Reminder.create_reminders(o1, c1, [u1.id])
    res[:resent].should == [u1.id]

    # all
    Reminder.destroy_all
    res = Reminder.create_reminders_for_all_users(o1, c1)
    ap res
    res[:created].sort.should == [u1.id, u2.id].sort
    res[:ignored].should == [u3.id]
    res[:resent].should be_empty
    res[:error].should be_empty
  end

end
