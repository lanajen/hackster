class AddFieldsToMouserContest < ActiveRecord::Migration
  def change
    remove_column :mouser_submissions, :status, :integer
    add_column :mouser_submissions, :status, :string
  end
end
