class UserObserver < ActiveRecord::Observer
  def after_create record
    record.broadcast :new, record.id, 'User'
  end

  def after_update record
    if (record.changes.keys - %w(email password roles_mask updated_at)).size > 0
      record.broadcast :update, record.id, 'User'
    end
  end
end