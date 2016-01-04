class LiveEventSetDecorator < ApplicationDecorator
  def name
    model.name.present? ? model.name : model.event_type.capitalize
  end

  def location
    if model.virtual
      'Online'
    else
      [model.city, model.country].select{|v| v.present? }.join(', ')
    end
  end

  def organizer_collection_for_form
    if model.persisted? and model.organizer
      { "#{model.organizer.name} (#{model.organizer.user_name})" => model.organizer_id }
    else
      {}
    end
  end
end