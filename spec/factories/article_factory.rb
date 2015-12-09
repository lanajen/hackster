FactoryGirl.define do
  factory :article do
    name { FFaker::Movie.title }
  end
end
