class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :avatar_url

  def avatar_url
    object.decorate.avatar
  end

  def url
    url_for [object, only_path: true]
  end
end