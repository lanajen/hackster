class AddImpressionsCountToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :impressions_count, :integer
  end
end
