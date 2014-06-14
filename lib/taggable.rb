module Taggable
  module ClassMethods
    def taggable *tags
      tags.each do |tag_type|
        attr_accessible :"#{tag_type}_string"
        has_many tag_type, -> { order(name: :asc) }, as: :taggable, dependent: :destroy
        after_save :"save_#{tag_type}"
        self.send :define_method, "#{tag_type}_string" do
          eval "
            @#{tag_type}_string ||= #{tag_type}.order(:name).pluck(:name).join(', ')
          "
        end
        self.send :define_method, "#{tag_type}_string=" do |val|
          eval "
            @#{tag_type}_string_was = #{tag_type}_string
            @#{tag_type}_string = val
          "
        end
        self.send :define_method, "#{tag_type}_string_was" do
          eval "
            @#{tag_type}_string_was ||= #{tag_type}_string
          "
        end
        self.send :define_method, "#{tag_type}_string_changed?" do
          eval "
            #{tag_type}_string_was != #{tag_type}_string
          "
        end
        self.send :define_method, "save_#{tag_type}" do
          eval "
            tags = #{tag_type}_string.split(',').map{ |s| s.strip }
            existing = #{tag_type}.pluck(:name)
            (tags - existing).each do |tag|
              #{tag_type}.create(name: tag) if tag.present?
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