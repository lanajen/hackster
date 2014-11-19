require File.join(Rails.root, 'lib/rewardino_lib/rewardino')

Rewardino.setup do |config|
  config.default_image = 'badges/default.png'
end

Rewardino::Badge.create!({
  code: :profile_completed,
  name: 'Profile completed',
  description: "Completed their profile.",
  explanation: "completing your profile.",
  condition: -> (nominee) {
    nominee.profile_complete?
  },
  image: '',
  level: :green,
})
# Rewardino::Trigger.set 'users#after_registration_save', action: :set_badge,
#   badge_codes: :profile_completed
Rewardino::Trigger.set 'users#update', action: :set_badge,
  badge_codes: :profile_completed

Rewardino::Badge.create!({
  code: :respected_project,
  name: 'First project respected',
  description: "Respected a project.",
  explanation: "respecting your first project.",
  condition: -> (nominee) {
    nominee.respects_count >= 1
  },
  revokable: true,
  image: '',
  level: :green,
})
Rewardino::Trigger.set ['respects#create', 'respects#destroy'],
  action: :set_badge, badge_codes: :respected_project

Rewardino::Badge.create!({
  code: :followed_platform,
  name: 'First platform followed',
  description: "Followed a platform.",
  explanation: "following your first platform.",
  condition: -> (nominee) {
    nominee.teches_count >= 1
  },
  revokable: true,
  image: '',
  level: :green,
})
Rewardino::Trigger.set ['followers#create', 'followers#destroy'], {
  action: :set_badge,
  badge_codes: :followed_platform,
  condition: -> (context) {
    context.instance_variable_get('@followable').type == 'Tech'
  },
}

Rewardino::Badge.create!({
  code: :followed_user,
  name: 'First hacker followed',
  description: "Followed a hacker.",
  explanation: "following your first hacker.",
  condition: -> (nominee) {
    nominee.followed_users_count >= 1
  },
  revokable: true,
  image: '',
  level: :green,
})
Rewardino::Trigger.set ['followers#create', 'followers#destroy'], {
  action: :set_badge,
  badge_codes: :followed_user,
  condition: -> (context) {
    context.instance_variable_get('@followable').type == 'User'
  },
}

Rewardino::Badge.create!({
  code: :commented_on_project,
  name: 'First comment on a project',
  description: "Commented on a project.",
  explanation: "commenting on a project for the first time.",
  condition: -> (nominee) {
    nominee.comments_count >= 1
  },
  revokable: true,
  image: '',
  level: :green,
})
Rewardino::Trigger.set ['comments#create', 'comments#destroy'], {
  action: :set_badge,
  badge_codes: :commented_on_project,
  condition: -> (context) {
    context.instance_variable_get('@commentable').class == Project
  },
}

Rewardino::Badge.create!({
  code: :joined_hacker_space,
  name: 'First hacker space joined',
  description: "Joined a hacker space.",
  explanation: "joining your first hacker space.",
  condition: -> (nominee) {
    nominee.hacker_spaces.count >= 1
  },
  revokable: true,
  image: '',
  level: :green,
})
Rewardino::Trigger.set 'group_invitations#accept', {
  action: :set_badge,
  badge_codes: :joined_hacker_space,
  condition: -> (context) {
    context.instance_variable_get('@group').type == 'HackerSpace'
  }
}

Rewardino::Badge.create!({
  code: :created_project,
  name: 'First project published',
  description: "Created and published their first project.",
  explanation: "Publishing your first project.",
  image: '',
  condition: -> (nominee) {
    nominee.projects.live.approved.any?
  },
  level: :green,
})
Rewardino::Trigger.set 'admin/projects#update', {
  action: :set_badge,
  badge_codes: :created_project,
  condition: -> (context) {
    context.instance_variable_get('@project').approved
  },
  nominee_variable: '@team_members',
}


# achievements
Rewardino::Badge.create!({
  code: :useful_feedback,
  name: 'Useful feedback',
  description: "Gave useful feedback on sombebody else's project.",
  explanation: "giving useful feedback on somebody else's project.",
  image: '',
  condition: -> (nominee) {
    false  # prevent automatic attribution
  },
  level: :bronze,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_codes: :useful_feedback

Rewardino::Badge.create!({
  code: :detailed_project,
  name: 'Detailed project',
  description: "Created a detailed and well formatted project, with code, bill of material, schematics and instructions.",
  explanation: "creating a detailed and well formatted project.",
  image: '',
  condition: -> (nominee) {
    false  # prevent automatic attribution
  },
  level: :bronze,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_codes: :detailed_project

Rewardino::Badge.create!({
  code: :helped_a_hacker,
  name: 'Helped a hacker',
  description: "Answered a question that was asked on their own project.",
  explanation: "answering a question that was asked in the comments section of your own project.",
  image: '',
  condition: -> (nominee) {
    false  # prevent automatic attribution
  },
  level: :bronze,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_codes: :helped_a_hacker

Rewardino::Badge.create!({
  code: :altruist,
  name: 'Altruist',
  description: "Answered a question that was asked on sombebody else's project.",
  explanation: "answering a question that was asked in the comments of somebody else's project.",
  image: '',
  condition: -> (nominee) {
    false  # prevent automatic attribution
  },
  level: :bronze,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_codes: :altruist


# recognition
Rewardino::Badge.create!({
  code: :project_respected_lvl0,
  name: 'First respect received',
  description: "Received a respect on a project.",
  explanation: "having one of your projects respected for the first time.",
  image: '',
  condition: -> (nominee) {
    nominee.active_profile? and nominee.projects.includes(:respects).count(:respects) >= 1
  },
  level: :green,
})
Rewardino::Badge.create!({
  code: :project_respected_lvl1,
  name: 'Received 10+ respects',
  description: "Received 10+ respects on a project.",
  explanation: "having one of your projects respected 10+ times.",
  image: '',
  condition: -> (nominee) {
    nominee.active_profile? and nominee.projects.includes(:respects).count(:respects) >= 10
  },
  level: :bronze,
})
Rewardino::Badge.create!({
  code: :project_respected_lvl2,
  name: 'Received 100+ respects',
  description: "Received 100+ respects on a project.",
  explanation: "having one of your projects respected 100+ times.",
  image: '',
  condition: -> (nominee) {
    nominee.active_profile? and nominee.projects.includes(:respects).count(:respects) >= 100
  },
  level: :silver,
})
Rewardino::Trigger.set ['respects#create', 'respects#destroy'], {
  action: :set_badge,
  badge_codes: [:project_respected_lvl0, :project_respected_lvl1, :project_respected_lvl2],
  background: true,
  nominee_variable: '@team_members',
}

Rewardino::Badge.create!({
  code: :profile_followed_lvl0,
  name: 'First follower',
  description: "Had their profile followed by another hacker.",
  explanation: "having your profile followed by another hacker.",
  image: '',
  condition: -> (nominee) {
    nominee.class == User and nominee.active_profile? and nominee.followers_count >= 1
  },
  level: :green,
})
Rewardino::Badge.create!({
  code: :profile_followed_lvl1,
  name: '10+ followers',
  description: "Had their profile followed by 10+ hackers.",
  explanation: "having your profile followed by 10+ hackers.",
  image: '',
  condition: -> (nominee) {
    nominee.class == User and nominee.active_profile? and nominee.followers_count >= 10
  },
  level: :bronze,
})
Rewardino::Trigger.set ['followers#create', 'followers#destroy'], {
  action: :set_badge,
  badge_codes: [:profile_followed_lvl0, :profile_followed_lvl1],
  nominee_variable: '@followable',
  background: true,
}

Rewardino::Badge.create!({
  code: :project_viewed_lvl0,
  name: '100+ views on a project',
  description: "Hit 100 views on one of their projects.",
  explanation: "hitting 100 views on one of your projects.",
  image: '',
  condition: -> (nominee) {
    nominee.projects.each do |project|
      return true if project.impressions_count >= 100
    end
    false
  },
  level: :green,
})
Rewardino::Badge.create!({
  code: :project_viewed,
  name: '1,000+ views on a project',
  description: "Hit 1,000 views on one of their projects.",
  explanation: "hitting 1,000 views on one of your projects.",
  image: '',
  condition: -> (nominee) {
    nominee.projects.each do |project|
      return true if project.impressions_count >= 1000
    end
    false
  },
  level: :bronze,
})
Rewardino::Badge.create!({
  code: :project_viewed_lvl2,
  name: '10,000+ views on a project',
  description: "Hit 10,000 views on one of their projects.",
  explanation: "hitting 10,000 views on one of your projects.",
  image: '',
  condition: -> (nominee) {
    nominee.projects.each do |project|
      return true if project.impressions_count >= 10000
    end
    false
  },
  level: :silver,
})
Rewardino::Badge.create!({
  code: :project_viewed_lvl3,
  name: '100,000+ views on a project',
  description: "Hit 100,000 views on one of their projects.",
  explanation: "hitting 100,000 views on one of your projects.",
  image: '',
  condition: -> (nominee) {
    nominee.projects.each do |project|
      return true if project.impressions_count >= 100000
    end
    false
  },
  level: :gold,
})
Rewardino::Trigger.set :cron, action: :set_badge,
  badge_codes: [:project_viewed_lvl0, :project_viewed_lvl1, :project_viewed_lvl2, :project_viewed_lvl3],
  background: true

# Rewardino::Badge.create!({
#   code: :project_featured,
#   name: '',
#   description: "",
#   image: '',
#   level: :silver,
# })
# Rewardino::Trigger.set :manual, action: :set_badge,
#   badge_codes: :project_featured, background: true


Rewardino::Trigger.all.freeze
Rewardino::Triggers = Rewardino::Trigger.all