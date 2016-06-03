require 'spec_helper'

describe ReminderJob do
  let(:reminder) { create :reminder }
  let(:course) { reminder.orgs_course.course }

  subject do
    ReminderJob.new reminder.id
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it '#reminder' do
    subject.reminder.should == reminder
  end

  describe '#perform' do
    it 'send' do
      subject.perform
      reminder.reload
      reminder.should be_reminder_sent
    end

    it 'complete' do
      course.user_events.create! user: reminder.user, event_type: 'course_end'

      subject.perform
      reminder.reload
      reminder.should be_reminder_completed
    end
  end

end
