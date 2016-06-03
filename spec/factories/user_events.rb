# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_event do
    event_time { Time.now }
    event_type "course_begin"
  end
end
