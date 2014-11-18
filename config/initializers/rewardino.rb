require File.join(Rails.root, 'lib/rewardino_lib/rewardino')

Rewardino.setup do |config|
  config.default_image = 'badges/default.png'
end

Rewardino::Badge.create!({
  code: :registered,
  name: 'Registered',
  description: 'Registered on Hackster.',
  explanation: "registering on Hackster.",
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set ['users/registrations#create',
  'users/simplified_registrations#create'], action: :set_badge,
  badge_code: :registered

Rewardino::Badge.create!({
  code: :profile_completed,
  name: 'Profile completed',
  description: "Completed their profile.",
  explanation: "completing your profile.",
  condition: -> (nominee) {
    nominee.profile_complete?
  },
  image: '',
  level: :getting_started,
})
# Rewardino::Trigger.set 'users#after_registration_save', action: :set_badge,
#   badge_code: :profile_completed
Rewardino::Trigger.set 'users#update', action: :set_badge,
  badge_code: :profile_completed

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
  level: :getting_started,
})
Rewardino::Trigger.set ['respects#create', 'respects#destroy'],
  action: :set_badge, badge_code: :respected_project

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
  level: :getting_started,
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
  name: 'First hacker followed',
  description: "Followed a hacker.",
  explanation: "following your first hacker.",
  condition: -> (nominee) {
    nominee.followed_users_count >= 1
  },
  revokable: true,
  image: '',
  level: :getting_started,
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
  name: 'First comment on a project',
  description: "Commented on a project.",
  explanation: "commenting on a project for the first time.",
  condition: -> (nominee) {
    nominee.comments_count >= 1
  },
  revokable: true,
  image: '',
  level: :getting_started,
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
  name: 'First hacker space joined',
  description: "Joined a hacker space.",
  explanation: "joining your first hacker space.",
  condition: -> (nominee) {
    nominee.hacker_spaces.count >= 1
  },
  revokable: true,
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set 'group_invitations#accept', {
  action: :set_badge,
  badge_code: :joined_hacker_space,
  condition: -> (context) {
    context.instance_variable_get('@group').type == 'HackerSpace'
  }
}

# Rewardino::Badge.create!({
#   code: :imported_project,
#   name: '',
#   description: "Imported a project to their profile.",
#   condition: -> (nominee) {
#     # finished transaction with no error?
#   },
#   image: '',
#   level: :getting_started,
# })
# Rewardino::Trigger.set 'project_imports#create', action: :set_badge,
#   badge_code: :imported_project

# Rewardino::Badge.create!({
#   code: :linked_project,
#   name: '',
#   description: "",
#   condition: -> (nominee) {
#     context.external == true
#   },
#   image: '',
#   level: :getting_started,
# })
# Rewardino::Trigger.set :manual, action: :set_badge,
#   badge_code: :linked_project

Rewardino::Badge.create!({
  code: :created_project,
  name: 'First project published',
  description: "Created and published their first project.",
  explanation: "Publishing your first project.",
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :created_project


# achievements
Rewardino::Badge.create!({
  code: :useful_feedback,
  name: 'Useful feedback',
  description: "Gave useful feedback on sombebody else's project.",
  explanation: "giving useful feedback on somebody else's project.",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :useful_feedback

Rewardino::Badge.create!({
  code: :detailed_project,
  name: 'Detailed project',
  description: "Created a detailed and well formatted project, with code, bill of material, schematics and instructions.",
  explanation: "creating a detailed and well formatted project.",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :detailed_project

Rewardino::Badge.create!({
  code: :helped_a_hacker,
  name: 'Helped a hacker',
  description: "Answered a question that was asked on their own project.",
  explanation: "answering a question that was asked in the comments section of your own project.",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :helped_a_hacker

Rewardino::Badge.create!({
  code: :altruist,
  name: 'Altruist',
  description: "Answered a question that was asked on sombebody else's project.",
  explanation: "answering a question that was asked in the comments of somebody else's project.",
  image: 'badges/altruist.png',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :altruist


# recognition
Rewardino::Badge.create!({
  code: :project_respected,
  name: 'Received a respect',
  description: "Received a respect on their own project.",
  explanation: "having one of your projects respected for the first time.",
  image: '',
  condition: -> (nominee) {
    nominee.project_respects_count >= 1
  },
  level: :silver,
})
Rewardino::Trigger.set ['respects#create', 'respects#destroy'], {
  action: :set_badge,
  badge_code: :project_respected,
  background: true,
  nominee_variable: '@team_members',
}

Rewardino::Badge.create!({
  code: :profile_followed,
  name: 'Profile followed',
  description: "Had their profile followed by another hacker.",
  explanation: "having your profile followed by another hacker.",
  image: '',
  condition: -> (nominee) {
    nominee.class == User and nominee.followers_count >= 1
  },
  level: :silver,
})
Rewardino::Trigger.set ['followers#create', 'followers#destroy'], {
  action: :set_badge,
  badge_code: :profile_followed,
  nominee_variable: '@followable',
  background: true,
}

Rewardino::Badge.create!({
  code: :project_viewed,
  name: '1,000 views on a project',
  description: "Hit 1,000 views on one of their projects.",
  explanation: "hitting 1,000 views on one of your projects.",
  image: '',
  condition: -> (nominee) {
    nominee.projects.each do |project|
      return true if project.impressions_count >= 1000
    end
    false
  },
  level: :silver,
})
Rewardino::Trigger.set :cron, action: :set_badge,
  badge_code: :project_viewed, background: true

# Rewardino::Badge.create!({
#   code: :project_featured,
#   name: '',
#   description: "",
#   image: '',
#   level: :silver,
# })
# Rewardino::Trigger.set :manual, action: :set_badge,
#   badge_code: :project_featured, background: true


Rewardino::Trigger.all.freeze
Rewardino::Triggers = Rewardino::Trigger.all