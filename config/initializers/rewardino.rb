require File.join(Rails.root, 'lib/rewardino_lib/rewardino')

Rewardino.setup do |config|
  # config.activate = false
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
    followable = context.instance_variable_get('@followable')
    followable.respond_to?(:type) and followable.type == 'Platform'
  },
}

Rewardino::Badge.create!({
  code: :followed_user,
  name_: 'First fellow-member followed',
  description_: "Followed a fellow member.",
  explanation_: "following your first fellow member.",
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
    context.instance_variable_get('@commentable').class == BaseArticle
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
    gold: 50,
  },
})
Rewardino::Trigger.set :cron, action: :set_badge, badge_code: :created_project,
  background: true


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
  code: :answered_question_own,
  name_: 'Answered a question on own project',
  description_: "Answered a question that was asked on their own project.",
  explanation_: "answering a question that was asked in the comments section of your own project.",
  image: '',
  levels: { bronze: 1 },
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :answered_question_own

Rewardino::Badge.create!({
  code: :answered_question_other,
  name_: "Answered a question on someone else's project",
  description_: "Answered a question that was asked on sombebody else's project.",
  explanation_: "answering a question that was asked in the comments of somebody else's project.",
  image: '',
  levels: { bronze: 1 },
})
Rewardino::Trigger.set :manual, action: :set_badge,
  badge_code: :answered_question_other

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
    silver: 50,
    gold: 150,
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
  description_: "Had their profile followed by |threshold|+ members.",
  explanation_: "having your profile followed by |threshold|+ members.",
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
    silver: 50,
    gold: 150,
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


Rewardino::Event.create!({
  code: :approved_project,
  name: 'Project approved',
  description: "One of your projects got approved to show on Hackster",
  points: 50,
  date_method: -> (project) { project.review_time || project.made_public_at },
  # model_table: 'projects',
  models_method: -> (user) { user.projects.own.where(type: %w(Article Project)).approved },
  users_count_method: -> (project) { project.team_members_count }
})

Rewardino::Event.create!({
  code: :reviewed_project,
  name: 'Project reviewed',
  description: "You reviewed a project",
  points: 5,
  date_method: -> (decision) { decision.created_at },
  models_method: -> (user) { user.is?(:admin, :hackster_moderator) ? [] : user.review_decisions.approved }
})

# Rewardino::Event.create!({
#   code: :approved_article,
#   name: 'Article approved',
#   description: "One of your articles got approved to show on Hackster",
#   points: 15,
#   date_method: -> (project) { project.review_time || project.made_public_at },
#   models_method: -> (user) { user.projects.articles.approved }
# })

# Rewardino::Event.create!({
#   code: :accepted_invitation_inviter,
#   name: 'Friend invitation accepted',
#   description: "A friend you invited has accepted their invitation",
#   points: 15,
#   date_method: -> (user) { user.invitation_accepted_at },
#   # model_table: 'users',
#   models_method: -> (user) { user.invitees.invitation_accepted }
# })

# Rewardino::Event.create!({
#   code: :new_comment,
#   name: 'New comment',
#   description: "You posted a new comment",
#   points: 10,
#   date_method: -> (comment) { comment.created_at },
#   # model_table: 'comments',
#   models_method: -> (user) { user.comments.where(commentable_type: 'BaseArticle') }
# })

Rewardino::Event.create!({
  code: :new_respect,
  name: 'New respect',
  description: "One of your projects received a new respect",
  points: 5,
  date_method: -> (respect) { respect.created_at },
  # model_table: 'respects',
  models_method: -> (user) { Respect.where(respectable_type: 'BaseArticle').joins('INNER JOIN projects ON projects.id = respects.respectable_id').joins('INNER JOIN groups ON groups.id = projects.team_id').joins('INNER JOIN members ON members.group_id = groups.id').where('members.user_id = ?', user.id) },
  users_count_method: -> (respect) { respect.respectable.team_members_count }
})

Rewardino::Event.create!({
  code: :viewed_project,
  name: 'Project viewed',
  description: "One of your projects was viewed one more time and reached a new threashold",
  points: [
    { every: 100, limit: 10, points: 5 },
    { every: 10_000, limit: 1, points: 50 },
  ],
  date_method: -> (impression) { impression.created_at },
  # model_table: 'impressions',
  compute_method: -> (event, user, date) {
    date = nil
    event.points.each do |conf|
      models = ProjectImpression.joins("INNER JOIN projects ON projects.id = project_impressions.project_id").where(projects: { id: user.projects.own.where("projects.impressions_count >= ?", conf[:every]).pluck(:id) }).order(:created_at)
      # models = models.where("#{event.model_table}.#{event.date_method} > ?", date) if date
      models.group_by(&:project_id).each do |id, group|

        project = group.first.project
        next unless user_count = project.team_members_count and user_count > 0
        points = (conf[:points] / user_count).ceil.to_i

        slice_index = 0
        group.each_slice(conf[:every]) do |slice|
          slice_index += 1
          next if slice_index > conf[:limit]

          if slice.size == conf[:every]
            last = slice.last
            ReputationEvent.create event_name: event.code, event_model: last, points: points, event_date: event.date_method.call(last), user_id: user.id
          end
        end
      end
    end
  },
})

Rewardino::Event.create!({
  code: :liked_thought,
  name: 'Comment liked',
  description: "One of your comments was liked one more time and reached a new threashold",
  points: [
    { every: 1, limit: 10, points: 5 },
  ],
  date_method: -> (like) { like.created_at },
  # model_table: 'respects',
  compute_method: -> (event, user, date) {
    event.points.each do |conf|
      models = Respect.where(respectable_type: %w(Comment)).joins("INNER JOIN comments ON comments.id = respects.respectable_id").where("comments.user_id = ? AND respects.user_id <> ?", user.id, user.id).order(:created_at)
      models += Respect.where(respectable_type: %w(Thought)).joins("INNER JOIN thoughts ON thoughts.id = respects.respectable_id").where("thoughts.user_id = ? AND respects.user_id <> ?", user.id, user.id).order(:created_at)
      # models = models.where("#{event.model_table}.#{event.date_method} > ?", date) if date

      models.group_by{|r| [r.respectable_id, r.respectable_type]}.each do |id, group|

        slice_index = 0
        group.each_slice(conf[:every]) do |slice|
          slice_index += 1
          next if slice_index > conf[:limit]

          if slice.size == conf[:every]
            last = slice.last
            ReputationEvent.create event_name: event.code, event_model: last, points: conf[:points], event_date: event.date_method.call(last), user_id: user.id
          end
        end
      end
    end
  },
})

Rewardino::Event.create!({
  code: :signup_user,
  name: 'Registered',
  description: "Welcome to Hackster!",
  points: 1,
  date_method: -> (user) { user.invitation_accepted_at || user.created_at },
  # model_table: 'users',
  models_method: -> (user) { [user] },
  boolean_method: -> (event, user) {
    user.invitation_token.nil? or user.invitation_accepted_at.present?
  }
})