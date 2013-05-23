class AddCaptionToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :caption, :string
  end
end
