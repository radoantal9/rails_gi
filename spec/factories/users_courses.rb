# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :users_course do
    user

    before :create do |obj|
      if obj.user && !obj.course
        obj.course = create :course
        create :orgs_course, org: obj.user.org, course: obj.course
        obj.user.reload
      end
    end
  end
end
