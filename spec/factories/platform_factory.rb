FactoryGirl.define do
  factory :platform do
    full_name { FFaker::Food.fruit }

    transient do
      part nil
      parts nil
    end

    after(:build) do |platform|
      platform.hidden = false
    end

    trait :with_part do
      after(:create) do |platform, evaluator|
        platform.parts << evaluator.part
      end
    end

    trait :with_parts do
      after(:create) do |platform, evaluator|
        # # Parts Observer handles the counter, we need to set the platform id to each part by hand to kick it off.
        evaluator.parts.each do |part|
          part.platform_id = platform.id
          part.save
        end
      end
    end
  end
end