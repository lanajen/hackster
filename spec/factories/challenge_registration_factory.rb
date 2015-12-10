FactoryGirl.define do
  factory :challenge_registration do

    transient do
      challenge nil
      user nil
    end

    before(:create) do |registration, evaluator|
      registration.challenge = evaluator.challenge
      registration.user = evaluator.user
    end
  end
end