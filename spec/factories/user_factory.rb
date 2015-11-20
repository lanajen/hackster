FactoryGirl.define do
  factory :user do
    user_name { FFaker::Internet.user_name.gsub('.', '-') }
    email { "#{user_name}@example.com" }
    email_confirmation { email }
    password { email }
  end
end
