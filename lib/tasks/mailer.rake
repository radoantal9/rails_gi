namespace :mailer do
  desc "Send notifications: daily, weekly or monthly"
  task :notification, [:period] => :environment do |t, args|
    pp args
    User.send_notifications(args[:period])
  end
end
