# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :content_storage do
    sequence(:content_data) {|n| "content_data #{n}" }

    after :build do |obj|
      obj.content_hash = ContentStorage.generate_hash(obj.content_data)
    end
  end
end
