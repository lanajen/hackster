class PartsController < ApplicationController
  before_filter :load_platform_with_slug
  before_filter :load_part, only: [:show, :embed]
  load_resource except: [:index]
  layout 'platform'

  def index
    @page_title = "Components made by #{@platform.name}"
    title @page_title
    meta_desc "Discover all the products made by #{@platform.name} and their related hardware projects."
    @parts = @platform.parts.default_sort.paginate(page: safe_page_params)
  end

  def sub_index
    @page_title = "Components based on #{@platform.name}'s technology"
    title @page_title
    meta_desc "Discover all the products based on #{@platform.name}'s technology and their related hardware projects."
    @parts = @platform.sub_parts.paginate(page: safe_page_params)

    render 'index'
  end

  def show
    title "#{@platform.name} #{@part.name} projects"
    meta_desc "Discover hardware projects made with #{@platform.name} #{@part.name}."
    @part = @part.decorate
    @projects = @part.projects.public.paginate(page: safe_page_params)
  end

  def embed
    per_page = begin; [Integer(params[:per_page]), Project.per_page].min; rescue; Project.per_page end;  # catches both no and invalid params
    @projects = @part.projects.paginate(per_page: per_page, page: safe_page_params)
    render layout: 'embed'
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