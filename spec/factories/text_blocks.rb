# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :text_block do
    sequence(:private_title) {|n| "private_title #{n}" }
    sequence(:raw_content) {|n| "raw_content #{n}" }
  end
end
