module ProjectHelper
  def select_tag_for_part_join join, options={}
    if part = join.part
      option_attrs = {
        value: join.part_id,
        'data-name' => part.name,
        'data-store_link' => part.store_link,
        'data-product_page_link' => part.product_page_link,
        'data-image_url' => part.image.try(:imgix_url, :part_thumb),
        'data-status' => part.workflow_state,
        'data-url' => (part.has_own_page? ? part_url(part) : nil)
      }
      if platform = part.platform
        option_attrs.merge!(
          'data-platform-id' => part.platform_id,
          'data-platform-name' => platform.name,
          'data-platform-logo_url' => platform.avatar.try(:imgix_url, :tiny),
        )
      end
      option_val = part.full_name
    else
      option_val = options[:prompt]
    end

    name = "project[#{[options[:part_type], 'part_joins_attributes'].compact.join('_')}][#{options[:i]}][part_id]"
    option_id = ["project", options[:part_type], options[:i], "name"].compact.join('_')
    content_tag(:div,
      content_tag(:label,
        content_tag(:abbr, '*', title: 'required') +
        content_tag(:span, ' ' + options[:label]),
        class: 'control-label'
      ) +
      content_tag(:select,
        content_tag(:option, option_val, option_attrs),
        class: 'form-control select2', name: name, id: option_id, 'data-placeholder' => options[:prompt], 'data-type' => options[:part_type], 'data-link-type' => options[:link_type]
      ),
      class: 'form-group'
    )
  end
end