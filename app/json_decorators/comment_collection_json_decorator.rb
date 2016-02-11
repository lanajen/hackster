class CommentCollectionJsonDecorator < BaseCollectionJsonDecorator
  def sorted_node
    node = {}
    node[:comments] = collection.map do |comment_id, comment|
      {
        root: CommentJsonDecorator.new(comment[:root], @opts).node,
        children: comment[:children].map{|c| CommentJsonDecorator.new(c, @opts).node }
      }
    end
    node
  end
end