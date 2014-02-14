class TechesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_tech, only: [:show, :update]
  layout 'tech', only: [:edit, :update, :show]
  respond_to :html

  def show
    authorize! :read, @tech
    title @tech.name
    meta_desc "People are hacking with #{@tech.name} on Hackster.io. Join them!"
    @broadcasts = @tech.broadcasts.limit 20
    @projects = @tech.projects

    render "groups/teches/#{self.action_name}"
  end

  def edit
    @tech = Tech.find(params[:id])
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

          render "groups/teches/#{self.action_name}"
        end

        track_event 'Updated tech'
      end
    else
      @tech.build_avatar unless @tech.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: @tech.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_tech
      @tech = load_with_user_name Tech
    end
end