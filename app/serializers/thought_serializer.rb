class ThoughtSerializer < MessageSerializer
  include ApplicationHelper

  attributes :link, :link_data

  has_many :comments, embed: :id, include: true

  def link_data
    object.link_datum ? LinkDatumSerializer.new(object.link_datum, root: false) : []
  end
end
