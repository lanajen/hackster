class PartsController < ApplicationController
  before_filter :load_platform_with_slug
  before_filter :load_part, only: [:show, :embed]
  load_resource except: [:index]
  layout 'platform'

  def index
    @page_title = @platform.parts_text
    title @page_title
    meta_desc "Discover all the #{@platform.parts_text.sub(/^[A-Z]/) {|f| f.downcase }} and their related hardware projects."
    @parts = @platform.parts.visible.default_sort.paginate(page: safe_page_params)
    @challenge = @platform.active_challenge ? @platform.challenges.active.first : nil
  end

  def sub_index
    @page_title = "Products based on #{@platform.name}'s technology"
    title @page_title
    meta_desc "Discover all the products based on #{@platform.name}'s technology and their related hardware projects."
    @parts = @platform.sub_parts.paginate(page: safe_page_params)

    render 'index'
  end

  def show
    title "#{@part.full_name} projects"
    @meta_desc = if @part.projects_count > 0
      "#{ActionController::Base.helpers.pluralize @part.projects_count, 'hardware project'} made with #{@part.name} from #{@platform.name}."
    else
      "Share your hardware projects made with #{@part.name} from #{@platform.name}."
    end
    meta_desc @meta_desc
    @projects = @part.projects.publyc.magic_sort.paginate(page: safe_page_params)
    @part = @part.decorate
    @challenge = @platform.active_challenge ? @platform.challenges.active.first : nil
  end

  def embed
    per_page = begin; [Integer(params[:per_page]), BaseArticle.per_page].min; rescue; BaseArticle.per_page end;  # catches both no and invalid params
    @projects = @part.projects.publyc.paginate(per_page: per_page, page: safe_page_params)
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