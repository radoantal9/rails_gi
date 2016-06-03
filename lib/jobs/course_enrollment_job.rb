CourseEnrollmentJob = Struct.new(:course_id, :user_id) do
  def perform
    course = Course.find_by_id(course_id)
    user = User.find_by_id(user_id)

    if course && user && user.courses.include?(course)
      mail = UserMailer.course_enrollment_email(user, course)
      mail.deliver

      Rails.logger.info "CourseEnrollmentJob perform #{course_id} #{user_id}"
      sleep APP_CONFIG['mailer_sleep'].to_i
    else
      Rails.logger.error "!CourseEnrollmentJob #{course_id} #{user_id}"
    end
  end

  def max_attempts
    100
  end
end
