class Tag < ActiveRecord::Base
  attr_accessible :name, :taggable_id, :taggable_type, :type
  belongs_to :taggable, polymorphic: true
  validates :name, presence: true
  before_save :remove_leading_pound

  def self.unique_names
    distinct(:name)
  end

  private
    def remove_leading_pound
      self.name = name.gsub(/^\#/, '')
    end
end
