# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :course_page do
    after :build do |obj|
      obj.page_num = obj.course.page_count + 1
    end
  end
end
