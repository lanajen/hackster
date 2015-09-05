class ListObserver < ActiveRecord::Observer
  def after_destroy record
    Cashier.expire 'lists-index' if record.public?
  end

  def after_save record
    if (record.changed & %w(full_name private mini_resume)).any?
      Cashier.expire "list-#{record.id}-thumb"
      Cashier.expire 'lists-index'
    end
  end

  def before_create record
    record.update_counters assign_only: true
  end

  def before_update record
  end
end