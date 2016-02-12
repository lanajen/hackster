class BaseJsonDecorator
  include JsonDecoratorHelpers
  attr_accessor :model

  def initialize model, opts={}
    @model = model
    @opts = opts
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
end