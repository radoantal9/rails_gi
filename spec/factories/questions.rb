require Rails.root.join('spec/support', 'question_xml_samples.rb')

FactoryGirl.define do
  sequence(:title) {|n| "This is a test #{n} question title #{n}" }

  factory :question do
    title
    
    trait :survey_question do
      content QuestionXMLSamples::SURVEY
    end
  end
end
