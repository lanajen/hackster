class SlugHistory < ActiveRecord::Base
  belongs_to :sluggable, polymorphic: true
  validates :value, presence: true
  attr_accessible :value, :sluggable_id, :sluggable_type

  def self.update_history_for project_id
    project = Project.find project_id
    histories = project.slug_histories
    uris = { project.uri => false }
    project.users.each{ |u| puts project.uri(u.user_name).to_s; uris[project.uri(u.user_name)] = false }

    histories.each do |history|
      # if a slug exists we mark it so it's last updated
      if history.value.in? uris
        history.touch
        uris[history.value] = true
      end
    end

    # if no slug could be found we create a new one
    uris.select{|k,v| v == false}.each do |uri, presence|
      create value: uri, sluggable_id: project.id, sluggable_type: 'Project'

      if where(value: uri).count > 1
        message = "A duplicate slug_history url has been created: project_id: #{project.id} // project_uri: #{project.uri}"
        log_line = LogLine.create(message: message, log_type: 'error', source: 'slug_history')
        NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification'
      end
    end
  end
end
