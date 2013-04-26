# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity_feed do
    broadcastable_type "MyString"
    broadcastable_id 1
    event "MyString"
    context_model_id 1
  end
end
