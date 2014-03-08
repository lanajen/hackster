class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.integer :gradable_id, null: false
      t.string :gradable_type, null: false
      t.string :grade, limit: 3
      t.text :feedback
      t.integer :project_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :grades, [:gradable_type, :gradable_id]
    add_index :grades, :project_id
    add_index :grades, :user_id

    add_column :assignments, :grading_type, :string
    add_column :assignments, :graded, :boolean, default: false
    add_column :assignments, :private_grades, :boolean, default: true
    add_column :projects, :graded, :boolean, default: false
  end
end
