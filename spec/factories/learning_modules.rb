# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :learning_module do
    sequence(:name) {|n| "Module #{n}" }
    text_block

    trait :with_lessons do
      after :create do |obj|
        obj.lessons << create(:lesson, :with_pages)
        obj.lessons << create(:lesson)
        obj.lessons << create(:lesson, :with_pages)
      end
    end

    trait :with_simple_lesson do
      after :create do |obj|
        obj.lessons << create(:lesson, :with_pages)
      end
    end
  end
end
