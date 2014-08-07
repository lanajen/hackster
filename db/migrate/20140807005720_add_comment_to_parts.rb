class AddCommentToParts < ActiveRecord::Migration
  def change
    add_column :parts, :comment, :string
  end
end
