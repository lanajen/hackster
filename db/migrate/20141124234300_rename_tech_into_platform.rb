class RenameTechIntoPlatform < ActiveRecord::Migration
  def change
    rename_column :challenges, :tech_id, :platform_id
    rename_column :subdomains, :tech_id, :platform_id
    rename_column :projects, :tech_tags_string, :platform_tags_string
  end
end
