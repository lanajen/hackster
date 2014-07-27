class AddBuyLinkToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :buy_link, :string
  end
end
