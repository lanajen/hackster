class ExternalProjectObserver < BaseArticleObserver
  def before_create record
    record.made_public_at = record.created_at
    super
  end

  def before_update record
    if (record.changed & %w(website)).any?
      Cashier.expire "project-#{record.id}-thumb"
    end
    super
  end
end