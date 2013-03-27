class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.text :body
      t.integer :bloggable_id, null: false
      t.string :bloggable_type, null: false
      t.boolean :private
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :blog_posts, [:bloggable_id, :bloggable_type]
    add_index :blog_posts, :user_id
  end
end
