# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :content_page do
    sequence(:name) {|n| "content_page #{n}" }

    trait :with_quiz do
      after :create do |obj|
        obj.add_element create(:quiz)
      end
    end

    trait :with_elements do
      after :create do |obj|
        obj.add_element create(:text_block)
        obj.add_element create(:quiz)
        obj.add_element create(:text_block)
      end
    end

  end
end
