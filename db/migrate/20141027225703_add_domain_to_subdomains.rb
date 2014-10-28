class AddDomainToSubdomains < ActiveRecord::Migration
  def change
    add_column :subdomains, :domain, :string
    add_column :subdomains, :tech_id, :integer
    add_index :subdomains, :domain
    add_index :subdomains, :tech_id
  end
end
