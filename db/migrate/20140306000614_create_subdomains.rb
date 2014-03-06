class CreateSubdomains < ActiveRecord::Migration
  def change
    create_table :subdomains do |t|
      t.string :subdomain
      t.string :name

      t.timestamps
    end
  end
end
