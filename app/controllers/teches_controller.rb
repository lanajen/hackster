class TechesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :embed]
  before_filter :load_tech, except: [:show, :embed]
  layout 'tech', only: [:edit, :update, :show]
  respond_to :html

  def show
    @tech = load_with_slug
    authorize! :read, @tech
    title @tech.name
    meta_desc "People are hacking with #{@tech.name} on Hackster.io. Join them!"
    @broadcasts = @tech.broadcasts.limit 20

    get_projects

    render "groups/teches/#{self.action_name}"
  end

  def embed
    @tech = load_with_slug
    title "Projects made with #{@tech.name}"
    @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    # @list_style = '_horizontal'
    get_projects
    render "groups/teches/#{self.action_name}", layout: 'embed'
  end

  private
  def get_projects
    # TODO: below is SUPER hacky. Would be great to just separate featured projects from the rest
    page = params[:page].try(:to_i) || 1
    per_page = Project.per_page
    @projects = @tech.projects.indexable_and_external.includes(:respects).where(respects: { respecting_id: @tech.id, respecting_type: 'Group' }).offset((page - 1) * per_page).limit(per_page)
    if @projects.to_a.size < per_page
      all_featured = @tech.projects.indexable_and_external.includes(:respects).where(respects: { respecting_id: @tech.id, respecting_type: 'Group' }).pluck(:id)
      offset = (page - 1) * per_page
      offset -= all_featured.size if @projects.to_a.size == 0
      @projects += @tech.projects.indexable_and_external.where.not(id: all_featured).offset(offset).limit(per_page - @projects.to_a.size)
    end
    total = @tech.projects.indexable_and_external.size

    @projects = WillPaginate::Collection.create(page, per_page, total) do |pager|
      pager.replace(@projects.to_a)
    end
  end

  public
  def edit
    authorize! :update, @tech
    @tech.build_avatar unless @tech.avatar

    render "groups/teches/#{self.action_name}"
  end

  def update
    authorize! :update, @tech
    old_tech = @tech.dup

    if @tech.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @tech, notice: 'Profile updated.' }
        format.js do
          @tech.avatar = nil unless @tech.avatar.try(:file_url)
          # if old_group.interest_tags_string != @tech.interest_tags_string or old_group.skill_tags_string != @tech.skill_tags_string
          if old_tech.user_name != @tech.user_name
            @refresh = true
          end
          @tech = GroupDecorator.decorate(@tech)

          render "groups/teches/#{self.action_name}"
        end

        track_event 'Updated tech'
      end
    else
      @tech.build_avatar unless @tech.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @tech.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_tech
      @tech = Tech.find(params[:id])
    end
end