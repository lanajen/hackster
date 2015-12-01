FactoryGirl.define do
  factory :group do
    full_name { FFaker::Movie.title }
  end
end
