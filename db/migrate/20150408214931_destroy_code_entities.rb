class DestroyCodeEntities < ActiveRecord::Migration
  def change
    drop_table :code_entities
  end
end
