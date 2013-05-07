# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :privacy_setting, :class => 'PrivacySettings' do
    privatable_type "MyString"
    privatable_id 1
    privacy_level "MyString"
  end
end
