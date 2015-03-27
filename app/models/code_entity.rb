class CodeEntity < ActiveRecord::Base

  belongs_to :project

  attr_accessible :repository, :name, :position, :comment, :type

  def name
    read_attribute(:name).presence || 'Untitled'
  end

  def file_type
    repository? ? 'repository' : 'code'
  end

  def repository?
    type == 'CodeRepository'
  end
end
