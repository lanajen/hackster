class ProjectObserver < ActiveRecord::Observer
  def after_create record
    %w(concept prototype final).each do |name|
      record.stages.create(name: name)
    end
  end
end