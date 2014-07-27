class PaypalWidget < Widget
  define_attributes [:code, :caption]
  # attr_accessible :code
  before_save :sanitize_code

  def self.model_name
    Widget.model_name
  end

  # def code
  #   Marshal.load(Base64.decode64(encoded_code)) if encoded_code.present?
  # end

  # def code=(val)
  #   self.encoded_code = Base64.encode64(Marshal.dump(val))
  # end

  def to_text
    "<div class='paypal-widget'>#{code}<p class='caption'>#{caption}</p></div>"
  end

  private
    def sanitize_code
      return unless code.present?

      self.code = Sanitize.clean(code, Sanitize::Config::PAYPAL_FORM)
    end
end
