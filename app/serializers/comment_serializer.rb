class CommentSerializer < ActiveModel::Serializer
  include ApplicationHelper

  attributes :id, :body, :timestamp, :liked, :own, :deleted, :edited, :commentable_id

  has_one :user, embed: :id, include: true

  def date
    time_diff_in_natural_language object.created_at, Time.now, ' ago'
  end

  def deleted
    !object.persisted?
  end

  def edited
    object.created_at != object.updated_at
  end

  def liked
    Respect.to_be? current_user, object
  end

  def timestamp
    object.created_at.to_i
  end

  def own
    current_user == user
  end
end
