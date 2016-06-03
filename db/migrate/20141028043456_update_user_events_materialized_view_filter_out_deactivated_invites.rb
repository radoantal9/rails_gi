class UpdateUserEventsMaterializedViewFilterOutDeactivatedInvites < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW user_events_materalized_view"
    select_sql= File.open("#{Rails.root}/db/migrate/20141028043456_update_user_events_materialized_view_filter_out_deactivated_invites.sql", 'r') { |f| f.read }
    view_sql = "create materialized view user_events_materalized_view as  #{select_sql}"
    execute view_sql

    add_index :user_events_materalized_view, :email
    add_index :user_events_materalized_view, :status
    add_index :user_events_materalized_view, :org_id
    add_index :user_events_materalized_view, [:org_id, :course_id]
    add_index :user_events_materalized_view, :first_name
    add_index :user_events_materalized_view, :last_name
    add_index :user_events_materalized_view, :course_id
    add_index :user_events_materalized_view, :course_title
    add_index :user_events_materalized_view, :percent_completed
    add_index :user_events, [:user_id, :course_id] unless index_exists?(:user_events, [:user_id, :course_id])
    add_index :user_events, [:user_id, :course_id, :event_type] unless index_exists?(:user_events, [:user_id, :course_id, :event_type])

    add_index :user_events_materalized_view, [:email, :course_id]

    add_index :user_events_materalized_view, [:id, :email, :course_id ], :unique => true, name: 'index_matview_on_id_email_course_id'
    add_index :user_events_materalized_view, [:course_id, :percent_completed], name: 'index_matview_on_course_id_percent_completed'
  end

  def down
  end
end
