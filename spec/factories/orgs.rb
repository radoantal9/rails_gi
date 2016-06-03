# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :org do
    sequence(:name) {|n| "Org #{n}" }
    # sequence(:domain) {|n| "org#{n}" } # restrict student email domain
    description "description"
    is_active true
    contact "contact"
    notes "notes"
    sequence(:signup_key) {|n| "singup_key_#{n}" }
  end
end
