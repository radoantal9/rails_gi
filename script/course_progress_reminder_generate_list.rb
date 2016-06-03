require 'yaml'# Used one time for Crystal Springs (orgid=7) group

config_data = YAML.load_file "script/reminder_email_settings.yml"

org         = Org.find_by_id(config_data["org"])
course      = Course.find_by_id(config_data["course"])
deadline    = config_data["deadline"]
message     = config_data["message"]
course_length_in_hours = config_data["course_length_in_hours"]
f_email_list = config_data["file_target_email_list"]

puts "Total users for org:" + org.users.count.to_s

# Get all users into a CSV file, the completed users will be used for encouragement stats in the email
File.open(f_email_list, 'w') do |f|

  org.users.each do |u|
    if u.has_role? :student
      pct = course.user_completion u
      puts "#{u.email} = #{pct}"
      f.puts("#{u.email},#{pct}")
    else
      "Skipping non student #{u.email}"
    end
  end

end

puts "Done. Wrote to file: #{f_email_list}"
