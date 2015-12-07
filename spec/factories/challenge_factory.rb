FactoryGirl.define do
  factory :challenge do
    name { FFaker::Sport.name }
    start_date Time.now
    end_date 10.days.from_now
    auto_approve true

    transient do
      platform nil
      fields nil
    end

    after(:create) do |challenge|
      challenge.generate_slug
    end

    trait :in_progress do
      after(:create) do |challenge|
        challenge.workflow_state = 'in_progress'
        challenge.save
      end
    end

    trait :with_platform do
      after(:create) do |challenge, evaluator|
        challenge.platform = evaluator.platform
      end
    end

    trait :with_fields do
      after(:create) do |challenge, evaluator|
        evaluator.fields.each do |field|
          challenge.challenge_idea_fields << field
        end
      end
    end
  end

  factory :challenge_idea_field do
    label { FFaker::Color.name }

    transient do
      position 0
    end

    after(:build) do |field, evaluator|
      field.position = evaluator.position || 0
    end

    trait :hide do
      hide true
    end

    trait :required do
      required true
    end
  end
end