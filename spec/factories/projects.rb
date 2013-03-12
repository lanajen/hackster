# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    user_id 1
    name "MyString"
    description "MyText"
    start_date "2013-03-11"
    end_date "2013-03-11"
  end
end
