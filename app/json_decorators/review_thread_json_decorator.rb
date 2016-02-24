class ReviewThreadJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id workflow_state locked))
    node[:decisions] = ReviewDecisionCollectionJsonDecorator.new(model.decisions).node
    node[:comments] = CommentCollectionJsonDecorator.new(model.comments).node
    node[:events] = ReviewEventCollectionJsonDecorator.new(model.events).node
    node
  end
end