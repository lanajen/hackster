class CreateLinkData < ActiveRecord::Migration
  def change
    create_table :link_data do |t|
      t.string :title
      t.string :website_name
      t.text :description
      t.string :extra_data_value1
      t.string :extra_data_value2
      t.string :extra_data_label1
      t.string :extra_data_label2
      t.string :link, null: false

      t.timestamps null: false
    end
    add_index :link_data, :link
  end
end
