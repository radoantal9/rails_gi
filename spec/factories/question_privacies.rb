# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question_privacy do
    course nil
    org nil
    question nil
    question_privacy_cd 1
  end
end
