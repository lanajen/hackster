class BaseCollectionJsonDecorator
  attr_accessor :collection

  def initialize collection
    @collection = collection
  end

  private
    def h
      ActionController::Base.helpers
    end
end