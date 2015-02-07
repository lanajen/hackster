class PartsController < ApplicationController
  before_filter :load_platform_with_slug
  before_filter :load_part, only: [:show]
  load_resource except: [:index]
  layout 'group_shared'

  def index
    title "Parts for #{@platform.name}"
    meta_desc "Discover all the parts for #{@platform.name} and their related hardware hacks and projects."
    @parts = @platform.parts.paginate(page: safe_page_params)
  end

  def show
    title "#{@platform.name} #{@part.name} projects and hacks"
    meta_desc "Discover hardware hacks and projects made with #{@platform.name} #{@part.name}."
    @projects = @part.projects.paginate(page: safe_page_params)
    @part = @part.decorate
  end

  private
    def load_part
      @part = if params[:id]
        Part.find params[:id]
      else
        Part.where(slug: params[:part_slug], platform_id: @platform.id).first!
      end
    end

    def load_platform_with_slug
      @group = @platform = load_with_slug
      authorize! :read, @platform
    end
end