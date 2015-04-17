class InfoRequest
  PLANS = [
    'Platform channel for startups',
    'Platform channel for enterprise',
    'Product challenge',
    'Product tutorial',
    'Product workshop',
    'Product hackathon',
  ]

  REFERRALS = [
    'Twitter',
    'Facebook',
    'LinkedIn',
    'Meetup',
    'Hackathon',
    'Google',
    'Friend or colleague',
  ]

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :company, :website, :plan, :needs, :referral, :name, :email,
    :phone, :location

  validates :company, :website, :plan, :needs, :name, :email, :phone,
    :location, :referral, presence: true

  def initialize attributes={}
    attributes.each do |attribute, value|
      send "#{attribute}=", value
    end
  end
end