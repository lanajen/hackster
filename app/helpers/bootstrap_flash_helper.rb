module BootstrapFlashHelper
  ALERT_TYPES = %w(danger info success warning)

  def bootstrap_flash classes='fade alert-top alert-flat in'
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = 'success' if type == 'notice'
      type = 'danger'  if type == 'error' or type == 'alert'
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                  content_tag(:div,
                     content_tag(:button, raw("&times;"), :class => "btn-close close", "data-close" => ".alert-top") +
                       msg.html_safe, class: 'container'), class: "alert alert-#{type} #{classes}")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end
end