FactoryGirl.define do
  factory :platform do
    full_name { FFaker::Food.fruit }

    transient do
      part nil
      parts nil
    end

    after(:build) do |platform|
      platform.hidden = false
      platform.generate_user_name()
    end

    trait :with_part do
      after(:create) do |platform, evaluator|
        platform.parts << evaluator.part
      end
    end

    trait :with_parts do
      worker = PartObserverWorker.new

      after(:create) do |platform, evaluator|
        evaluator.parts.each do |part|
          platform.parts << part
          worker.perform('after_commit', part.id)
        end
      end
    end
  end
end