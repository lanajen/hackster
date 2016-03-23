class UpdateAttachmentsTmpFile < ActiveRecord::Migration
  def change
    change_column :attachments, :tmp_file, :text
  end
end
