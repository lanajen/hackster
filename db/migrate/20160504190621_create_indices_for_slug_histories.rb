class CreateIndicesForSlugHistories < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        remove_index :slug_histories, :value

        execute <<-SQL
          CREATE INDEX index_slug_histories_on_value_lower
            ON slug_histories
            USING btree
            (LOWER(value), id ASC);
        SQL
      end
      dir.down do
        add_index :slug_histories, :value

        execute <<-SQL
          DROP INDEX index_slug_histories_on_value_lower;
        SQL
      end
    end
  end
end
