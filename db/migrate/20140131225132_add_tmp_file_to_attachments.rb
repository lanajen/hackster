class AddTmpFileToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :tmp_file, :string
  end
end
