ReminderJob = Struct.new(:reminder_id) do
  def perform
    if reminder.can_send_reminder?
      course = reminder.orgs_course.course

      if course.is_course_completed?(reminder.user)
        reminder.complete_reminder
      else
        UserMailer.org_course_email(reminder.user, course, 'reminder').deliver

        reminder.send_reminder

        Rails.logger.info "ReminderJob perform #{reminder_id}"
        sleep APP_CONFIG['mailer_sleep'].to_i
      end
    else
      Rails.logger.error "!ReminderJob can't send #{reminder_id}"
    end
  end

  def max_attempts
    1
  end

  def failure
    reminder.fail_reminder
    Rails.logger.error "!ReminderJob failure #{reminder_id}"
  end

  def error
    reminder.fail_reminder
    Rails.logger.error "!ReminderJob error #{reminder_id}"
  end

  def reminder
    @reminder ||= Reminder.find(reminder_id)
  end
end
