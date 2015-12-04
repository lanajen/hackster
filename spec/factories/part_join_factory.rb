FactoryGirl.define do
  factory :part_join do

    transient do
      part nil
      project nil
    end

    after(:build) do |part_join, evaluator|
      part_join.part = evaluator.part || create(:part)
      part_join.partable = evaluator.project || create(:project)
    end

    after(:create) do |part_join, evaluator|
      part_join.part.save!
      part_join.partable.save!
    end
  end
end