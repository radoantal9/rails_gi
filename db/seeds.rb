# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?
  # Demo users for [:admin, :student, :user_manager, :content_manager]
  User.valid_roles.each do |role|
    email = "#{role}@example.com" # admin@example.com

    u = User.where(:email => email).first
    u ||= User.new(:email => email, :password => '12345678', :password_confirmation => '12345678')
    u.org = Org.first
    u.roles = [role]
    u.save
  end
end
