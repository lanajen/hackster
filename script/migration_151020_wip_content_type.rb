ExternalProject.find_each{|p| p.update_attribute :content_type, :external }
Project.where(wip: true).find_each{|p| p.update_attribute :content_type, :wip }