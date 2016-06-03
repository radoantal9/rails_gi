FactoryGirl.define do
  factory :survey do

    association :question, :survey_question
    orgs_course
    # user
    survey_email { FFaker::Internet.email }
  end

end
