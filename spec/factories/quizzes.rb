# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :quiz do
    name "This is private quiz description"
    instructions "These instructions go on top of the quiz"
  end
end
