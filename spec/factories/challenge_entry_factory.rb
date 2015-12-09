FactoryGirl.define do
  factory :challenge_entry do

    transient do
      project nil
      challenge nil
      user nil
    end

    after(:build) do |entry, evaluator|
      entry.project = evaluator.project
      entry.challenge = evaluator.challenge
      entry.user = evaluator.user
    end

    after(:create) do |entry|
      entry.workflow_state = 'qualified'
      entry.save
    end
  end
end