require 'yaml'# Used one time for Crystal Springs (orgid=7) group
require 'csv'

config_data = YAML.load_file "script/reminder_email_settings.yml"

org         = Org.find_by_id(config_data["org"])
course      = Course.find_by_id(config_data["course"])
deadline    = config_data["deadline"]
message     = config_data["message"]
course_length_in_hours = config_data["course_length_in_hours"]
f_email_list = config_data["file_target_email_list"] #Read the user email list from here
f_sent_email_list = config_data["file_sent_email_list"] #Put the users who were sent emails here

target_list = {}

CSV.foreach(f_email_list) do |row|
  u_email, completion_pct = row
  target_list[u_email] = completion_pct
end

students_at_100_pct =  target_list.select{|k, v| v.to_i==100}.count

puts target_list

sent_email_list = []

target_list.each do |u_email, pct|
  begin
    user = User.find_by_email(u_email)
    if pct.to_i < 100 && user
      UserMailer.course_progress_reminder_email(user, course, course_length_in_hours*60, deadline, message, students_at_100_pct).deliver
      UserEvent.create! user: user, course: course, event_type: 'reminder_sent', event_time: Time.now
      sent_email_list << u_email
      puts "Sent email to #{u_email}.  Press enter to continue to next student..."
      a = gets.chomp
      #sleep(0.33) # Amazon SES throttles at 5 emails per/sec, so we send 3 emails per sec
    else
      puts "Skipping #{u_email} at #{pct}% and/or user not found for email: [#{u_email}]"
    end
  rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
    puts "*** ERROR *** Problem sending email to #{u_email}"
    puts e.inspect
  end

end

Time.zone = "EST"
File.open(f_sent_email_list, 'w') do |w|
  sent_email_list.each do |s|
     w.puts Time.zone.now.to_s + "," + s
  end
end
