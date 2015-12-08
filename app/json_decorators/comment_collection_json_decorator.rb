class CommentCollectionJsonDecorator < BaseCollectionJsonDecorator
  def node
    node = {}
    node[:comments] = collection.each do |comment_id, comment|
      {
        root: CommentJsonDecorator.new(comment[:root]).node,
        children: comment[:children].map{|c| CommentJsonDecorator.new(c).node }
      }
      node
    end
  end
end