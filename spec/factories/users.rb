FactoryGirl.define do
  factory :user do
    password 'wordpass'
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    email { FFaker::Internet.email("#{first_name} #{last_name}") }
    org

    # password_confirmation 'wordpass'
    # required if the Devise Confirmable module is used
    #confirmed_at Time.now
  end

  trait :admin do
    roles [:admin]
  end

  trait :manager do
    roles [:user_manager]
  end

  trait :content_manager do
    roles [:content_manager]
  end
  
  trait :student do
    user_detail
    org
    roles [:student]
  end

  trait :with_course do
    after :build do |obj|
      course = create :course, :with_modules
      create :orgs_course, course: course, org: obj.org
      obj.courses << course
    end
  end

  trait :with_simple_course do
    after :build do |obj|
      course = create :course, :with_simple_module
      create :orgs_course, course: course, org: obj.org
      obj.courses << course
    end
  end
end
