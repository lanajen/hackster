# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stage do
    project_id 1
    name "MyString"
    completion_rate 1
  end
end
