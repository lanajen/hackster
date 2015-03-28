module AdminHelper
  def options_for_array array, selected
    out = '<option></option>'
    array.each do |val|
      out += '<option'
      out += ' selected="selected"' if val.to_s == selected.to_s
      out += '>'
      out += html_escape(val).to_s
      out += '</option>'
    end
    out.html_safe
  end
end