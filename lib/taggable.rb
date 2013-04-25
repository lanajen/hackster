module Taggable
  module ClassMethods
    def taggable *tags
      tags.each do |tag_type|
        attr_accessible :"#{tag_type}_string"
        has_many tag_type, as: :taggable, dependent: :destroy
        self.send :define_method, "#{tag_type}_string" do
          eval "
            #{tag_type}.pluck(:name).join(', ')
          "
        end
        self.send :define_method, "#{tag_type}_string=" do |val|
          eval "
            tags = val.split(',').map{ |s| s.strip }
            existing = #{tag_type}.pluck(:name)
            (tags - existing).each do |tag|
              #{tag_type}.create name: tag
            end
            deleted = existing - tags
            #{tag_type}.where('tags.name IN (?)', deleted).destroy_all if deleted.any?
          "
        end
      end
    end
  end

  module InstanceMethods

  end

  def self.included base
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end
end