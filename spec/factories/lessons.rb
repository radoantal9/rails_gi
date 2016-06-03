# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lesson do
    sequence(:name) {|n| "Lesson #{n}" }
    text_block

    trait :with_pages do
      after :create do |obj|
        obj.content_pages << create(:content_page, :with_elements)
        obj.content_pages << create(:content_page)
        obj.content_pages << create(:content_page, :with_elements)
      end
    end
  end
end
