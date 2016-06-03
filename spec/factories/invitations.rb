# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do
    orgs_course
    invitation_email { FFaker::Internet.email }
  end
end
