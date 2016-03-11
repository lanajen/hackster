class ReviewThreadJsonDecorator < BaseJsonDecorator
  def node opts={}
    node = hash_for(%w(id workflow_state locked))

    decisions = model.decisions
    decisions = decisions.publyc unless opts[:show_unapproved]

    node[:decisions] = ReviewDecisionCollectionJsonDecorator.new(decisions).node
    node[:comments] = CommentCollectionJsonDecorator.new(model.comments).node
    node[:events] = ReviewEventCollectionJsonDecorator.new(model.events).node
    node
  end
end