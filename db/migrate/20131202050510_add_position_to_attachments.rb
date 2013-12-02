class AddPositionToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :position, :integer
  end
end
