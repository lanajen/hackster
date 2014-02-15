class CreateUniversities < ActiveRecord::Migration
  def change
    create_table :courses_universities do |t|
      t.integer :university_id
      t.integer :course_id
    end
  end
end
