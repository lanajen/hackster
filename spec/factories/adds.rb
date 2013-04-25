# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :add do
    tag "MyString"
    taggable_id 1
    taggable_type "MyString"
    type ""
    name "MyString"
  end
end
