class UserObserver < ActiveRecord::Observer
  def after_create record
    record.broadcast :new, record.id, 'User'
  end

  def after_update record
    record.broadcast :update, record.id, 'User'
  end
end