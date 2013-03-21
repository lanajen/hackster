# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :research_paper do
    title "MyString"
    abstract "MyText"
    coauthors "MyString"
    published_on "2013-03-20"
    publication "MyString"
    link "MyString"
    user_id 1
  end
end
