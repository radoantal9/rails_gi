class UpdateStudentRegistrationStatus < ActiveRecord::Migration
  def up
    UserDetail.where(registration_state: 'require_photo').update_all(registration_state: 'registration_complete')
  end

  def down
  end
end
