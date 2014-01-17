class PaypalWidget < Widget
  define_attributes [:code]
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

  private
    def sanitize_code
      return unless code.present?

      self.code = Sanitize.clean(code, Sanitize::Config::PAYPAL_FORM)
    end
end
