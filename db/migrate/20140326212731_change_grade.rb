class ChangeGrade < ActiveRecord::Migration
  def change
    change_column :grades, :grade, :string, limit: nil
    add_column :grades, :type, :string, limit: 20, null: false, default: 'Grade'
    add_index :grades, :type
  end
end
