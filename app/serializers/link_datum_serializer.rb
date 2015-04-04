class LinkDatumSerializer < ActiveModel::Serializer
  attributes :link, :website_name, :title, :description, :extra_data_value1,
    :extra_data_value2, :extra_data_label1, :extra_data_label2, :image_link

  def image_link
    object.image.try(:file_url)
  end
end