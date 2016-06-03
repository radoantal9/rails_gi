InvitationJob = Struct.new(:invitation_id, :custom_email_subject, :custom_email_message) do
  def perform
    user = User.by_email(invitation.invitation_email).first
    if user
      invitation.accept_invitation
    else
      if invitation.can_send_invitation?
        mail = UserMailer.invitation_email(invitation, custom_email_subject, custom_email_message)
        mail.deliver

        invitation.send_invitation

        Rails.logger.info "InvitationJob perform #{invitation_id}"

        sleep APP_CONFIG['mailer_sleep'].to_i
      else
        Rails.logger.error "!InvitationJob can't send #{invitation_id}"
      end
    end
  end

  def max_attempts
    1
  end

  def failure
    invitation.fail_invitation
    Rails.logger.error "!InvitationJob failure #{invitation_id}"
  end

  def error
    invitation.fail_invitation
    Rails.logger.error "!InvitationJob error #{invitation_id}"
  end

  def invitation
    @invitation ||= Invitation.find(invitation_id)
  end
end
