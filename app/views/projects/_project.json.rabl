attributes :id, :name, :description

node do |project|
  {
    start_date: l(project.start_date, format: :default),
    end_date: project.end_date.present? ? l(project.end_date, format: :default) : 'Present',
    permissions: {
      edit: can?(:edit, project),
      destroy: can?(:destroy, project),
    },
    following: current_user.try(:is_following_project?, @project),
  }
end

child :team_members => :team_members do |project|
  attributes :role
  child :user do
    extends "users/show"
  end
end

child :images do
  node(:headline) {|i| i.file_url(:headline) }
  node(:small_thumb) {|i| i.file_url(:small_thumb) }
end