require 'rails/generators'
class Rewardino
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path("../../templates", __FILE__)

    def create_awarded_badges_model
      copy_file "app/models/awarded_badge.rb", "app/models/awarded_badge.rb"
    end

    def create_awarded_badges_migration
      time_str = Time.now.strftime("%Y%m%d%H%M%S")
      copy_file "db/migrate/create_table_awarded_badges.rb", "db/migrate/#{time_str}_create_table_awarded_badges.rb"
    end


  end
end
