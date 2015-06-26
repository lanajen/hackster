class AddLocaleToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :locale, :string, limit: 2, default: 'en'
    add_index :projects, :locale
  end
end
