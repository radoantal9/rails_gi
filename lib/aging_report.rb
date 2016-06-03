class AgingReport
  def self.find_users(org, course)
    UserEventsMaterializedView.org_course(org, course).where('percent_completed < 100')
  end
end
