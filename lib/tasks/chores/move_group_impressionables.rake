namespace :chores do
  desc 'Move Group-related Impressions to GroupImpressions'
  task move_group_impressionables: [:environment] do
    Chores::GroupImpressionMoveWorker.perform_async 'load_all'
  end
end
