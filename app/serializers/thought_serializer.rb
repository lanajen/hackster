class ThoughtSerializer < ActiveModel::Serializer
  include ApplicationHelper

  attributes :id, :body, :timestamp, :liked, :own, :deleted, :edited, :likes, :link,
    :link_data

  has_one :user, embed: :id, include: true
  has_many :comments, embed: :id, include: true

  def date
    time_diff_in_natural_language object.created_at, Time.now, ' ago'
  end

  def deleted
    !object.persisted?
  end

  def edited
    object.created_at != object.updated_at
  end

  def link_data
    object.link_datum ? LinkDatumSerializer.new(object.link_datum, root: false) : []
  end

  def liked
    Respect.to_be? current_user, object
  end

  def likes
    {
      count: object.likes.count,
      likers: object.liking_users.where.not(id: current_user.id).limit(2).map{|u| { name: u.name, url: url_for([u, only_path: true]) }}
    }
  end

  def timestamp
    object.created_at.to_i
  end

  def own
    current_user == user
  end
end
