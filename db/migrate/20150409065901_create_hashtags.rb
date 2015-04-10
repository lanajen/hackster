class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string :name
      t.text :cache_counters

      t.timestamps null: false
    end

    create_table :hashtag_thoughts do |t|
      t.integer :hashtag_id
      t.integer :thought_id
    end
    add_index :hashtag_thoughts, :hashtag_id
    add_index :hashtag_thoughts, :thought_id

    create_table :channel_hashtags do |t|
      t.integer :hashtag_id
      t.integer :channel_id
    end
    add_index :channel_hashtags, :hashtag_id
    add_index :channel_hashtags, :channel_id
  end
end
