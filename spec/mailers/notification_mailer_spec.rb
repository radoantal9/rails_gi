require "spec_helper"

describe NotificationMailer do
  let(:org) { create :org }
  let(:manager) { create :user, :manager, org: org }

  it '#activity_report' do
    c1 = create :course
    create :orgs_course, org: org, course: c1

    org2 = create :org
    create :orgs_course, org: org2, course: c1

    c2 = create :course
    create :orgs_course, org: org2, course: c2

    u1 = create :user, :student, org: org
    u2 = create :user, :student, org: org
    u3 = create :user, :student, org: org2
    u4 = create :user, :student, org: org2
    create :users_course, user: u1, course: c1
    create :users_course, user: u2, course: c1, created_at: 3.day.ago
    create :users_course, user: u3, course: c2
    create :users_course, user: u4, course: c1

    org.users.should include(u1, u2)
    org2.users.should include(u3)

    c1.users.should include(u1, u2)
    c2.users.should include(u3)

    manager.update_notifications 'activity_report_since' => 2.days.ago
    mail = NotificationMailer.activity_report(manager)
    #pp mail
    #pp mail.body.encoded

    mail.body.encoded.should include u1.email
    mail.body.encoded.should_not include u2.email
    mail.body.encoded.should_not include u3.email
    mail.body.encoded.should_not include u4.email
  end

  it '#signup_notification' do
    org2 = create :org
    u1 = create :user, :student, org: org, created_at: 3.days.ago
    u2 = create :user, :student, org: org, created_at: 1.day.ago
    u3 = create :user, :student, org: org2, created_at: 1.day.ago
    manager.update_notifications 'signup_notification_since' => 2.days.ago
    #pp u1
    #pp u2
    #pp manager.notifications

    mail = NotificationMailer.signup_notification(manager)
    #pp mail
    #pp mail.body.encoded

    mail.body.encoded.should include u2.email
    mail.body.encoded.should_not include u1.email
    mail.body.encoded.should_not include u3.email
  end

  it '#completion_notification' do
    c1 = create :course
    create :orgs_course, org: org, course: c1

    org2 = create :org
    create :orgs_course, org: org2, course: c1

    c2 = create :course
    create :orgs_course, org: org2, course: c2

    u1 = create :user, :student, org: org
    u2 = create :user, :student, org: org
    u3 = create :user, :student, org: org2
    u4 = create :user, :student, org: org2
    create :users_course, user: u1, course: c1
    create :users_course, user: u2, course: c1
    create :users_course, user: u3, course: c2
    create :users_course, user: u4, course: c1

    org.users.should include(u1, u2)
    org2.users.should include(u3, u4)

    c1.users.should include(u1, u2, u4)
    c2.users.should include(u3)

    u1.reload
    u2.reload
    u4.reload
    ev1 = create :user_event, user: u1, course: c1, event_type: 'course_end', event_time: 1.day.ago
    ev2 = create :user_event, user: u2, course: c1, event_type: 'course_end', event_time: 3.day.ago
    ev3 = create :user_event, user: u4, course: c1, event_type: 'course_end', event_time: 1.day.ago

    manager.update_notifications 'completion_notification_since' => 2.days.ago


    #mail = NotificationMailer.completion_notification(manager, u1, c1)
    mail = NotificationMailer.completion_notification(manager)
    mail.body.encoded.should include u1.email
    mail.body.encoded.should_not include u2.email
    mail.body.encoded.should_not include u3.email
    mail.body.encoded.should_not include u4.email

  end

  it '#mailing_stats' do
    c1 = create :course
    stats = { ignored: ['aaa@aaa.aaa'], enrolled: [], invited: ['ccc@ccc.ccc', 'ddd@ddd.ddd'], error: [] }
    mail = NotificationMailer.mailing_stats(manager, c1, 'invitations', stats)
    # puts mail.body.encoded

    mail.body.encoded.should include 'aaa@aaa.aaa'
  end
end
