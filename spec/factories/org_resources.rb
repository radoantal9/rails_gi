# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :org_resource do
    org
    sequence(:org_key) {|n| "org_key_#{n}" }
    sequence(:org_value) {|n| "Org Value #{n}" }

    factory :optional_org_resource do
      sequence(:org_key) {|n| "optional:org_key_#{n}" }
    end
  end

end
