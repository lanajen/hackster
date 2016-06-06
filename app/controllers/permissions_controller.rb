class PermissionsController < MainBaseController
  before_filter :authenticate_user!
  before_filter :load_permissible
  respond_to :html
  layout :set_layout

  def edit
    authorize! :update, @permissible
    @permissible.permissions.new unless @permissible.permissions.any?
    render template: "permissions/#{@model_name.pluralize}/edit"
  end

  def update
    authorize! :update, @permissible

    if @permissible.update_attributes(params[@model_name.to_sym])
      flash[:notice] = 'Permissions saved.'
      respond_with @permissible
    else
      render action: 'edit', template: "permissions/#{@model_name.pluralize}/edit"
    end
  end

  private
    def load_permissible
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @permissible = $1.classify.constantize.find(value)
          @model_name = @permissible.class.model_name.to_s.underscore
          instance_variable_set "@#{@model_name}", @permissible
          return
        end
      end
    end

    def set_layout
      @model_name
    end
end