class MainSubdomain < Subdomain
  def self.instance
    @@instance ||= new
  end

  def initialize
  end

  def logo
    Avatar.new
  end

  def name
    'Hackster.io'
  end

  def subdomain
    'www'
  end

  private_class_method :new
end