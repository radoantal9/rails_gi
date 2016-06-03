class CreateUserEvents < ActiveRecord::Migration
  def change
    create_table :user_events do |t|
      t.integer :user_id
      t.integer :course_id
      t.integer :learning_module_id
      t.integer :lesson_id
      t.integer :content_page_id
      t.string :event_type
      t.datetime :event_time
      t.hstore :event_data

      t.timestamps
    end

    add_index :user_events, :user_id
    add_index :user_events, :course_id
    add_index :user_events, :learning_module_id
    add_index :user_events, :lesson_id
    add_index :user_events, :content_page_id
    add_index :user_events, :event_type
    add_index :user_events, :event_time
  end
end
