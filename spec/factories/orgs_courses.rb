# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :orgs_course do
    org
    course
    sequence(:enrollment_code) {|n| "code#{n}".upcase }
  end
end
