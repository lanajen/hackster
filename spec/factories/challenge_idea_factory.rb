FactoryGirl.define do
  factory :challenge_idea do
    name { FFaker::DizzleIpsum.word }
    description { FFaker::DizzleIpsum.sentence }

    transient do
      challenge nil
      user nil
      image nil
    end

    after(:build) do |idea, evaluator|
      idea.challenge = evaluator.challenge
      idea.user = evaluator.user
      idea.image = evaluator.image || create(:image)
    end

    after(:create) do |idea|
      idea.save
    end

    trait :approved do
      after(:create) do |idea|
        idea.workflow_state = 'approved'
        idea.save
      end
    end
  end
end