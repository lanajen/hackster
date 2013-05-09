# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :participant_invite do
    project_id 1
    user_id 1
    email "MyString"
  end
end
