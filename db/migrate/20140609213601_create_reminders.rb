class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.references :orgs_course
      t.references :user
      t.string :reminder_state
      t.datetime :sent_at
      t.integer :sent_count, default: 0

      t.timestamps
    end

    add_index :reminders, :orgs_course_id
    add_index :reminders, :user_id
    add_index :reminders, :reminder_state
    add_index :reminders, :sent_at
  end
end
