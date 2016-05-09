class ChallengeCollectionJsonDecorator < BaseCollectionJsonDecorator
  def node
    _node = { challenges: super }
    _node[:total_pages] = @collection.total_pages
    _node[:page] = @collection.current_page
    _node
  end
end