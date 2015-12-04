FactoryGirl.define do
  factory :part do
    name { FFaker::Product.product_name }

    trait :hardware do
      type { 'HardwarePart' }
    end

    trait :software do
      type { 'SoftwarePart' }
    end

    after(:create) do |part|
      part.generate_slug
      part.approve!
    end
  end
end