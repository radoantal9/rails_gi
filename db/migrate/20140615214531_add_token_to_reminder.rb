class AddTokenToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :reminder_token, :string
    add_index :reminders, :reminder_token
  end
end
