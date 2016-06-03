# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :course do
    sequence(:name) {|n| "Course #{n}" }
    title
    text_block

    trait :with_simple_module do
      after :create do |obj|
        obj.learning_modules << create(:learning_module, :with_simple_lesson)
        obj.generate_course_pages
      end
    end

    trait :with_modules do
      after :create do |obj|
        obj.learning_modules << create(:learning_module, :with_lessons)
        obj.learning_modules << create(:learning_module)
        obj.learning_modules << create(:learning_module, :with_lessons)
        obj.generate_course_pages
      end
    end
  end
end
