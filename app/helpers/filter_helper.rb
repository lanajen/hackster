module FilterHelper
  def filter_for collection, fields
    params[:sort_by] ||= 'created_at'
    sort_by = fields[params[:sort_by]] || fields['created_at']
    params[:sort_order] ||= 'DESC'
    sort_order = params[:sort_order]
    sort = "#{sort_by} #{sort_order}"


    if filters = params[:filters]
      filters.each do |filter, value|
        field = fields[filter]
        next unless field and value.present?
        if value.is_number? or value == 't' or value == 'f'
          collection = collection.where("#{field} = ?", value)
        else
          collection = collection.where("#{field} ILIKE ?", "%#{value}%")
        end
      end
    end

    collection.order(sort).paginate(page: safe_page_params, per_page: params[:per_page])
  end
end