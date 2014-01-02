class ChangeProjectsFeaturedToDate < ActiveRecord::Migration
  def up
    add_column :projects, :featured_date, :datetime
    Project.where(featured: true).update_all(featured_date: Time.now)
    # remove_column :projects, :featured
  end

  def down
    # add_column :projects, :featured, :boolean
    # Project.where('featured_date IS NOT NULL').update_all(featured: true)
    remove_column :projects, :featured_date
  end
end
