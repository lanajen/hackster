FactoryGirl.define do
  factory :project do
    name { FFaker::Movie.title }
  end
end