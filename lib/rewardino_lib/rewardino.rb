require File.join(Rails.root,  'lib/rewardino_lib/rewardino/badge')
require File.join(Rails.root,  'lib/rewardino_lib/rewardino/trigger')
require File.join(Rails.root,  'lib/rewardino_lib/rewardino/status')
require File.join(Rails.root,  'lib/rewardino_lib/rewardino/nominee')
require File.join(Rails.root,  'lib/rewardino_lib/rewardino/controller_extension')

module Rewardino
  def self.setup
    @config ||= Configuration.new
    yield @config if block_given?
  end

  # # Define ORM
  def self.orm
    @config.orm
  end

  # Define user_model_name
  def self.user_model
    @config.user_model_name.constantize
  end

  # Define current_user_method
  def self.current_user_method trigger=nil
    trigger.try(:nominee_variable) || @config.current_user_method ||
      "current_#{@config.user_model_name.downcase}".to_sym
  end

  class Configuration
    attr_accessor :orm, :user_model_name, :current_user_method

    def initialize
      @orm = :active_record
      @user_model_name = 'User'
    end
  end

  setup

  class BadgeNotFound < StandardError; end

  class Engine < Rails::Engine
    initializer 'rewardino.controller' do |app|
      ActiveSupport.on_load(:action_controller) do
        begin
          # Load app rules on boot up
          Rewardino::Triggers = Rewardino::Trigger.all
          # Merit::AppPointRules = Merit::PointRules.new.defined_rules
          include Rewardino::ControllerExtension
        rescue NameError => e
          raise e
        end
      end
    end
  end
end