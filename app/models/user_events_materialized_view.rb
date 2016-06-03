class UserEventsMaterializedView < ActiveRecord::Base
  self.table_name = "user_events_materalized_view"

  scope :org, ->(org_id) { where(org_id: org_id) }
  scope :org_course, ->(org_id, course_id) { where(org_id: org_id, course_id: course_id) }

  def self.refresh!
    start = Time.now
    begin
      connection.execute("REFRESH MATERIALIZED VIEW #{table_name} WITH DATA")
      Rails.cache.write('UserEventsMaterializedView.updated_at', Time.now)
      Rails.cache.write('UserEventsMaterializedView.update_duration', Time.now - start)
    rescue => e
      Airbrake.notify_or_ignore(
          e,
          :cgi_data      => ENV.to_hash
      )
    end
  end

  def readonly?
    true
  end

  def self.delete_all
    raise ActiveRecord::ReadOnlyRecord
  end

  def delete
    raise ActiveRecord::ReadOnlyRecord
  end

  def self.destroy_all
    raise ActiveRecord::ReadOnlyRecord
  end

  def destroy
    raise ActiveRecord::ReadOnlyRecord
  end

end

