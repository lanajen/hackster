class GroupJsonDecorator < BaseJsonDecorator
  def node
    hash_for %w(id full_name)
  end
end