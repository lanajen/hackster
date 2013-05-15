class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.text :properties

      t.timestamps
    end
  end
end
