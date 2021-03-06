class InfoRequest
  PLANS = [
    'Starter Platform hub',
    'Professional Platform hub',
    'Contest',
    'Tutorial',
    'Hackster Live',
    'Hackathon',
    'Workshop',
  ]

  REFERRALS = [
    'Twitter',
    'Facebook',
    'LinkedIn',
    'Meetup',
    'Hackathon',
    'Google or other search engine',
    'Friend or colleague',
    'Other',
  ]

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :company, :website, :plan, :needs, :referral, :name, :email,
    :phone, :location, :promotional_code

  validates :company, :website, :plan, :needs, :name, :email, :phone,
    :location, :referral, presence: true

  def initialize attributes={}
    attributes.each do |attribute, value|
      send "#{attribute}=", value
    end
  end
end