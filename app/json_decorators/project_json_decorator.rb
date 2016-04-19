class ProjectJsonDecorator < BaseJsonDecorator
  def node
    node = model.map do |project|
      project = {
        :id => project.id,
        :name => project.name,
        :communities => project.platform_tags_string,
        :created_at => project.created_at.strftime('%Y-%m-%d'),
        :authors => project.users.map do |user|
          {
            :id => user.id,
            :name =>  user.name
          }
        end
      }
    end
    node
  end
end
