namespace :chores do
  desc 'Move Project-related Impressions to ProjectImpressions'
  task move_project_impressionables: [:environment] do
    Chores::ProjectImpressionMoveWorker.perform_async 'load_all'
  end
end
