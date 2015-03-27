class ChangeCaptionTypeInAttachments < ActiveRecord::Migration
  def change
    change_column :attachments, :caption, :text
  end
end
