# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reminder do
    orgs_course
    user { create :user, :student, org: orgs_course.org }

    after(:create) do |reminder, evaluator|
      reminder.user.courses << reminder.orgs_course.course
    end
  end
end
