# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_detail do
    registration_state 'registration_complete'

    user_data do
      { 'gender' => 'male', 'race' => 'white'}
    end

    trait :female do
      after :build do |obj|
        obj.user_data['gender'] = 'female'
      end
    end

  end
end
