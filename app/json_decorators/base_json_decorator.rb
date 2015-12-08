class BaseJsonDecorator
  attr_accessor :model

  def initialize model
    @model = model
  end

  private
    # A helper to extract attributes from an object,
    # calling getters on it.
    # Example:
    #   hash_for(user_instance, ["email"])
    #     -> calls user_instance.email
    #     The result will be: { email: "the email" }
    def hash_for(attributes)
      res = {}
      attributes.map do |attr|
        res[attr] = model.send attr
      end
      res
    end

    def h
      ActionController::Base.helpers
    end
end