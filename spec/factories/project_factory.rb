FactoryGirl.define do
  factory :project do
    name { FFaker::Movie.title }

    transient do
      user nil
      platform nil
    end

    after(:create) do |project, evaluator|
      user = evaluator.user || create(:user)
      team = project.build_team user_name: user.user_name
      project.team.members.new user_id: user.id
      project.pryvate = false
      project.workflow_state = 'approved'
      project.save!
    end

    trait :with_platform do
      after(:create) do |project, evaluator|
        platform = evaluator.platform || create(:platform)
        project.groups << platform
        project.save!
      end
    end
  end
end
