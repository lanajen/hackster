class AddUseAltToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :use_alt, :boolean, default: false
  end
end
