# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :course_mail do
    mail_object { create :course }
    email_type :enrollment
    email_subject { FFaker::Lorem.sentence }
    email_message { FFaker::Lorem.paragraph }
  end
end
