class CreateUserEventsMaterializedView < ActiveRecord::Migration
  def up
    select_sql= File.open("#{Rails.root}/db/migrate/20140908020620_create_user_events_materialized_view.sql", 'r') { |f| f.read }
    view_sql = "create materialized view user_events_materalized_view as  #{select_sql}"
    execute view_sql

    add_index :user_events_materalized_view, [:email, :course_id], :unique => true
    add_index :user_events_materalized_view, :email
    add_index :user_events_materalized_view, :org_id
    add_index :user_events_materalized_view, [:org_id, :course_id]
    add_index :user_events_materalized_view, :first_name
    add_index :user_events_materalized_view, :last_name
    add_index :user_events_materalized_view, :course_id
    add_index :user_events_materalized_view, :course_title
    add_index :user_events_materalized_view, :percent_completed
    add_index :user_events, [:user_id, :course_id] unless index_exists?(:user_events, [:user_id, :course_id])
    add_index :user_events, [:user_id, :course_id, :event_type] unless index_exists?(:user_events, [:user_id, :course_id, :event_type])

  end

  def down
    execute "DROP MATERIALIZED VIEW user_events_materalized_view"
  end
end
