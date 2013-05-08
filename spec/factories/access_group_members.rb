# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :access_group_member, :class => 'AccessGroupMembers' do
    access_group_id 1
  end
end
