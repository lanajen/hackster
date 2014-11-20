require File.join(Rails.root, 'lib/rewardino_lib/rewardino')

Rewardino.setup do |config|
  config.activate = false
  config.default_image = 'badges/default.png'
end

Rewardino::Badge.create!({
  code: :profile_completed,
  name_: 'Profile completed',
  description_: "Completed their profile.",
  explanation_: "completing your profile.",
  condition: -> (nominee, threshold) {
    nominee.profile_complete?
  },
  image: '',
  levels: { green: 1 },
})
Rewardino::Trigger.set 'users#update', action: :set_badge,
  badge_code: :profile_completed

Rewardino::Badge.create!({
  code: :respected_project,
  name_: 'First project respected',
  description_: "Respected a project.",
  explanation_: "respecting your first project.",
  condition: -> (nominee, threshold) {
    nominee.respects_count >= 1
  },
  revokable: true,
  image: '',
  levels: { green: 1 },
})
Rewardino::Trigger.set ['respects#create', 'respects#destroy'],
  action: :set_badge, badge_code: :respected_project

Rewardino::Badge.create!({
  code: :followed_platform,
  name_: 'First platform followed',
  description_: "Followed a platform.",
  explanation_: "following your first platform.",
  condition: -> (nominee, threshold) {
    nominee.teches_count >= 1
  },
  revokable: true,
  image: '',
  levels: { green: 1 },
})
Rewardino::Trigger.set ['followers#create', 'followers#destroy'], {
  action: :set_badge,
  badge_code: :followed_platform,
  condition: -> (context) {
    context.instance_variable_get('@followable').type == 'Tech'
  },
}

Rewardino::Badge.create!({
  code: :followed_user,
  name_: 'First hacker followed',
  description_: "Followed a hacker.",
  explanation_: "following your first hacker.",
  condition: -> (nominee, threshold) {
    nominee.followed_users_count >= 1
  },
  revokable: true,
  image: '',
  levels: { green: 1 },
})
Rewardino::Trigger.set ['followers#create', 'followers#destroy'], {
  action: :set_badge,
  badge_code: :followed_user,
  condition: -> (context) {
    context.instance_variable_get('@followable').type == 'User'
  },
}

Rewardino::Badge.create!({
  code: :commented_on_project,
  name_: 'First comment on a project',
  description_: "Commented on a project.",
  explanation_: "commenting on a project for the first time.",
  condition: -> (nominee, threshold) {
    nominee.comments_count >= 1
  },
  revokable: true,
  image: '',
  levels: { green: 1 },
})
Rewardino::Trigger.set ['comments#create', 'comments#destroy'], {
  action: :set_badge,
  badge_code: :commented_on_project,
  condition: -> (context) {
    context.instance_variable_get('@commentable').class == Project
  },
}

Rewardino::Badge.create!({
  code: :joined_hacker_space,
  name_: 'First hacker space joined',
  description_: "Joined a hacker space.",
  explanation_: "joining your first hacker space.",
  condition: -> (nominee, threshold) {
    nominee.hacker_spaces.count >= 1
  },
  revokable: true,
  image: '',
  levels: { green: 1 },
})
Rewardino::Trigger.set 'group_invitations#accept', {
  action: :set_badge,
  badge_code: :joined_hacker_space,
  condition: -> (context) {
    context.instance_variable_get('@group').type == 'HackerSpace'
  }
}

Rewardino::Badge.create!({
  code: :created_project,
  name_: '|threshold|+ projects published',
  description_: "Created and published |threshold|+ projects.",
  explanation_: "publishing |threshold|+ projects.",
  image: '',
  condition: -> (nominee, threshold) {
    nominee.projects.live.approved.count >= threshold
  },
  levels: {
    green: {
      threshold: 1,
      name_: 'First project published',
      description_: "Created and published their first project.",
      explanation_: "publishing your first project.",
    },
    bronze: 5,
    silver: 20,
  },
})
Rewardino::Trigger.set 'admin/projects#update', {
  action: :set_badge,
  badge_code: :created_project,
  condition: -> (context) {
    context.instance_variable_get('@project').approved
  },
  nominee_variable: '@team_members',
  background: true,
}


# achievements
Rewardino::Badge.create!({
  code: :useful_feedback,
  name_: 'Useful feedback',
  description_: "Gave useful feedback on sombebody else's project.",
  explanation_: "giving useful feedback on somebody else's project.",
  image: '',
  levels: { bronze: 1 },
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :useful_feedback

Rewardino::Badge.create!({
  code: :detailed_project,
  name_: 'Detailed project',
  description_: "Created a detailed and well formatted project, with code, bill of material, schematics and instructions.",
  explanation_: "creating a detailed and well formatted project.",
  image: '',
  levels: { bronze: 1 },
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :detailed_project

Rewardino::Badge.create!({
  code: :helped_a_hacker,
  name_: 'Helped a hacker',
  description_: "Answered a question that was asked on their own project.",
  explanation_: "answering a question that was asked in the comments section of your own project.",
  image: '',
  levels: { bronze: 1 },
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :helped_a_hacker

Rewardino::Badge.create!({
  code: :altruist,
  name_: 'Altruist',
  description_: "Answered a question that was asked on sombebody else's project.",
  explanation_: "answering a question that was asked in the comments of somebody else's project.",
  image: '',
  levels: { bronze: 1 },
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :altruist

Rewardino::Badge.create!({
  code: :project_respected,
  name_: 'Received |threshold|+ respects on a single project',
  description_: "Received |threshold|+ respects on a project.",
  explanation_: "having one of your projects respected |threshold|+ times.",
  image: '',
  condition: -> (nominee, threshold) {
    nominee.active_profile? and nominee.projects.each do |project|
      return true if project.respects_count >= threshold
    end
    false
  },
  levels: {
    green: {
      threshold: 1,
      name_: 'First respect received',
      description_: "Received their first respect on a project.",
      explanation_: "having one of your projects respected for the first time.",
    },
    bronze: 10,
    silver: 100,
  }
})
Rewardino::Trigger.set ['respects#create', 'respects#destroy'], {
  action: :set_badge,
  badge_code: :project_respected,
  background: true,
  nominee_variable: '@team_members',
}

Rewardino::Badge.create!({
  code: :profile_followed,
  name_: '|threshold|+ followers',
  description_: "Had their profile followed by |threshold|+ hackers.",
  explanation_: "having your profile followed by |threshold|+ hackers.",
  image: '',
  condition: -> (nominee, threshold) {
    nominee.class == User and nominee.active_profile? and nominee.followers_count >= threshold
  },
  levels: {
    green: {
      threshold: 1,
      name_: 'First follower',
      description_: "Had their profile followed for the first time.",
      explanation_: "having your profile followed for the first time.",
    },
    bronze: 10,
  }
})
Rewardino::Trigger.set ['followers#create', 'followers#destroy'], {
  action: :set_badge,
  badge_code: :profile_followed,
  nominee_variable: '@followable',
  background: true,
}

Rewardino::Badge.create!({
  code: :project_viewed,
  name_: "Project viewed |threshold|+ times",
  description_: "Hit |threshold|+ views on one of their projects.",
  explanation_: "hitting |threshold|+ views on one of your projects.",
  image: '',
  condition: -> (nominee, threshold) {
    nominee.projects.each do |project|
      return true if project.impressions_count >= threshold
    end
    false
  },
  levels: {
    green: 100,
    bronze: 1000,
    silver: 10000,
    gold: 100000,
  },
})
Rewardino::Trigger.set :cron, action: :set_badge, badge_code: :project_viewed,
  background: true


Rewardino::Trigger.all.freeze
Rewardino::Triggers = Rewardino::Trigger.all