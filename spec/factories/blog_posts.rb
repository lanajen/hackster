# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :blog_post do
    title "MyString"
    body "MyText"
    bloggable_id 1
    bloggable_type "MyString"
    private false
  end
end
