class UpdateIndexUserEventsMaterializedView < ActiveRecord::Migration
  def up
    # there are pesky non uniques in user and invitations so we need better unique index
    #     add_index :user_events_materalized_view, [:email, :course_id], :unique => true

    remove_index :user_events_materalized_view, [:email, :course_id]

    # add it back as a non-unique version
    add_index :user_events_materalized_view, [:email, :course_id]

    add_index :user_events_materalized_view, [:id, :email, :course_id ], :unique => true, name: 'index_matview_on_id_email_course_id'
    add_index :user_events_materalized_view, [:course_id, :percent_completed], name: 'index_matview_on_course_id_percent_completed'

  end

  def down
  end
end
