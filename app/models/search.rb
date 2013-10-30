class Search < ActiveRecord::Base
  attr_accessible :params, :results, :user_id

  def self.log options
    options[:params] = options[:params].to_yaml if :params.in? options
    create options
  end

  def params
    params = read_attribute :params
    params ? YAML::load(params) : {}
  end

  def query
    params['q']
  end

  def type
    params['type']
  end
end
