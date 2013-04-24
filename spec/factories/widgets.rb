# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :widget do
    type ""
    stage_id 1
    properties "MyText"
  end
end
