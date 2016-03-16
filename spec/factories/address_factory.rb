FactoryGirl.define do
  factory :address do
    full_name { FFaker::Movie.title }
    address_line1 { FFaker::Movie.title }
    city { FFaker::Movie.title }
    zip { FFaker::Movie.title }
    country { FFaker::Movie.title }
    phone { FFaker::Movie.title }
  end
end