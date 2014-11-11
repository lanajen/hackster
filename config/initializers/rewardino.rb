# Badginator.define_badge do
#   code :registered
#   name 'Registered'
#   description 'Registered'
#   # condition -> (nominee, context) {
#   #   true
#   # }
#   image 'http:://example.org/images/.gif'
#   level :getting_started
# end

# Badginator.define_trigger do
#   event 'users/registrations#create'
#   background false
#   action :set_badge
#   badge_code :registered
#   current_user :resource
# end

# require 'rewardino'

require File.join(Rails.root, 'lib/rewardino_lib/rewardino')

Rewardino::Badge.create!({
  code: :registered,
  name: 'Registered',
  description: 'Registered to Hackster.',
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set 'users/registrations#create', action: :set_badge,
  badge_code: :registered
Rewardino::Trigger.set 'users/simplified_registrations#create',
  action: :set_badge, badge_code: :registered

Rewardino::Badge.create!({
  code: :profile_completed,
  name: 'Profile completed',
  description: "Completed their profile.",
  condition: -> (nominee, context) {
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
  name: '',
  description: "Respected a project.",
  condition: -> (nominee, context) {
    nominee.respects_count > 0
  },
  revokable: true,
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set 'respects#create', action: :set_badge,
  badge_code: :respected_project
Rewardino::Trigger.set 'respects#destroy', action: :set_badge,
  badge_code: :respected_project

Rewardino::Badge.create!({
  code: :followed_platform,
  name: '',
  description: "Followed a platform.",
  condition: -> (nominee, context) {
    nominee.class == Tech and nominee.teches_count > 0
  },
  revokable: true,
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set 'followers#create', action: :set_badge,
  badge_code: :followed_platform
Rewardino::Trigger.set 'followers#destroy', action: :set_badge,
  badge_code: :followed_platform

Rewardino::Badge.create!({
  code: :followed_user,
  name: '',
  description: "Followed a user.",
  condition: -> (nominee, context) {
    nominee.class == User and nominee.followed_users_count > 0
  },
  revokable: true,
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set 'followers#create', action: :set_badge,
  badge_code: :followed_user
Rewardino::Trigger.set 'followers#destroy', action: :set_badge,
  badge_code: :followed_user

Rewardino::Badge.create!({
  code: :joined_hacker_space,
  name: '',
  description: "Joined a hacker space.",
  condition: -> (nominee, context) {
    context.instance_variable_get('@group').type == 'HackerSpace' and nominee.hacker_spaces.count > 0
  },
  revokable: true,
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set 'group_invitations#accept', action: :set_badge,
  badge_code: :joined_hacker_space

Rewardino::Badge.create!({
  code: :imported_project,
  name: '',
  description: "Imported a project to their profile.",
  condition: -> (nominee, context) {
    # finished transaction with no error?
  },
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set 'project_imports#create', action: :set_badge,
  badge_code: :imported_project

Rewardino::Badge.create!({
  code: :linked_project,
  name: '',
  description: "",
  condition: -> (nominee, context) {
    context.external == true
  },
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :linked_project

Rewardino::Badge.create!({
  code: :created_project,
  name: '',
  description: "Created and published their first project.",
  image: '',
  level: :getting_started,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :created_project


# achievements
Rewardino::Badge.create!({
  code: :useful_feedback,
  name: '',
  description: "Gave useful feedback to sombebody else's project.",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :useful_feedback

Rewardino::Badge.create!({
  code: :detailed_project,
  name: '',
  description: "Created a detailed and well formatted project, with code, bill of material, schematics and instructions.",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :detailed_project

Rewardino::Badge.create!({
  code: :helped_a_hacker,
  name: '',
  description: "Answered a question that was asked on their own project.",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :helped_a_hacker

Rewardino::Badge.create!({
  code: :altruist,
  name: '',
  description: "Answered a question that was asked on sombebody else's project.",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :altruist


# recognition
Rewardino::Badge.create!({
  code: :project_respected,
  name: '',
  description: "",
  image: '',
  condition: -> (nominee, context) {
    nominee.project_respects_count >= 1
  },
  level: :silver,
})
Rewardino::Trigger.set 'respects#create', {
  action: :set_badge,
  badge_code: :project_respected,
  background: true,
  nominee_variable: '@team_members',
}
Rewardino::Trigger.set 'respects#destroy', {
  action: :set_badge,
  badge_code: :project_respected,
  background: true,
  nominee_variable: '@team_members',
}

Rewardino::Badge.create!({
  code: :profile_followed,
  name: '',
  description: "",
  image: '',
  condition: -> (nominee, context) {
    nominee.class == User and nominee.followers_count >= 1
  },
  level: :silver,
})
Rewardino::Trigger.set 'followers#create', {
  action: :set_badge,
  badge_code: :profile_followed,
  nominee_variable: '@followable',
  background: true,
}
Rewardino::Trigger.set 'followers#destroy', {
  action: :set_badge,
  badge_code: :profile_followed,
  nominee_variable: '@followable',
  background: true,
}

Rewardino::Badge.create!({
  code: :project_viewed,
  name: '',
  description: "",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :cron, action: :set_badge,
  badge_code: :project_viewed, background: true

Rewardino::Badge.create!({
  code: :project_featured,
  name: '',
  description: "",
  image: '',
  level: :silver,
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :project_featured, background: true


Rewardino::Trigger.all.freeze
Rewardino::Triggers = Rewardino::Trigger.all