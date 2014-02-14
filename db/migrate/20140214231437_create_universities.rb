class CreateUniversities < ActiveRecord::Migration
  def change
    create_table :universities do |t|
      t.string :name
      t.string :city
      t.string :country

      t.timestamps
    end
    create_table :courses_universities do |t|
      t.integer :university_id
      t.integer :course_id
    end
  end
end
