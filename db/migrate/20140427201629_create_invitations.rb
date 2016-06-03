class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :orgs_course_id
      t.integer :user_id
      t.string :invitation_email
      t.string :invitation_state

      t.timestamps
    end

    add_index :invitations, :orgs_course_id
    add_index :invitations, :user_id
    add_index :invitations, :invitation_email
    add_index :invitations, :invitation_state
  end
end
