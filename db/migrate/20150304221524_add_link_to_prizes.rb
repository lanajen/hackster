class AddLinkToPrizes < ActiveRecord::Migration
  def change
    add_column :prizes, :link, :string
  end
end
