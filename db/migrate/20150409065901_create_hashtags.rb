class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string :name
      t.text :cache_counters

      t.timestamps null: false
    end

    create_table :hashtags_thoughts do |t|
      t.integer :hashtag_id
      t.integer :thought_id
    end
    add_index :hashtags_thoughts, :hashtag_id
    add_index :hashtags_thoughts, :thought_id

    create_table :channels_hashtags do |t|
      t.integer :hashtag_id
      t.integer :channel_id
    end
    add_index :channels_hashtags, :hashtag_id
    add_index :channels_hashtags, :channel_id
  end
end
