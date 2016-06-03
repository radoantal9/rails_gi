# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question_grade_report do
    score 1
    correct_answer { { 1 => 2 } }
    given_answer { { 1 => 2 } }
  end
end
