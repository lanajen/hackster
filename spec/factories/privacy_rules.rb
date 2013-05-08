# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :privacy_rule do
    private false
    privatable_id 1
    privatable_type "MyString"
  end
end
