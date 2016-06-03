SurveyJob = Struct.new(:survey_id) do
  def perform
    if survey.can_send_survey?
      UserMailer.survey_email(survey).deliver
      survey.send_survey

      Rails.logger.info "SurveyJob perform #{survey_id}"
      sleep APP_CONFIG['mailer_sleep'].to_i
    else
      Rails.logger.error "!SurveyJob can't send #{survey_id}"
    end
  end

  def max_attempts
    1
  end

  def failure
    survey.fail_survey
    Rails.logger.error "!SurveyJob failure #{survey_id}"
  end

  def error
    survey.fail_survey
    Rails.logger.error "!SurveyJob error #{survey_id}"
  end

  def survey
    @survey ||= Survey.find(survey_id)
  end
end
