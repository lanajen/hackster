FactoryGirl.define do
  factory :project_collection do

    transient do
      platform nil
      project nil
      user nil
    end

    trait :with_platform do
      after(:create) do |collection, evaluator|
        collection.project = evaluator.project || create(:project, user: evaluator.user)
        collection.collectable = evaluator.platform || create(:platform)
        collection.save!
      end
    end
  end
end