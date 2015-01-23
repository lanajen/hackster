class AddZipcodeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :zipcode, :string
  end
end
