class HackathonsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_hackathon, only: [:show, :update]
  # layout 'hackathon', only: [:edit, :update, :show]
  respond_to :html

  def show
    redirect_to event_path(@hackathon.events.last)
  end

  # def show
  #   authorize! :read, @hackathon
  #   title @hackathon.name
  #   meta_desc "#{@hackathon.name} students are learning on Hackster.io. Join them!"
  #   # @broadcasts = @hackathon.broadcasts.limit 20
  #   @projects = @hackathon.projects

  #   render "groups/hackathons/#{self.action_name}"
  # end

  # def edit
  #   @hackathon = Hackathon.find(params[:id])
  #   authorize! :update, @hackathon
  #   @hackathon.build_avatar unless @hackathon.avatar

  #   render "groups/hackathons/#{self.action_name}"
  # end

  # def update
  #   authorize! :update, @hackathon
  #   old_hackathon = @hackathon.dup

  #   if @hackathon.update_attributes(params[:group])
  #     respond_to do |format|
  #       format.html { redirect_to @hackathon, notice: 'Profile updated.' }
  #       format.js do
  #         @hackathon.avatar = nil unless @hackathon.avatar.try(:file_url)
  #         # if old_group.interest_tags_string != @hackathon.interest_tags_string or old_group.skill_tags_string != @hackathon.skill_tags_string
  #         if old_hackathon.user_name != @hackathon.user_name
  #           @refresh = true
  #         end

  #         render "groups/hackathons/#{self.action_name}"
  #       end

  #       track_event 'Updated hackathon'
  #     end
  #   else
  #     @hackathon.build_avatar unless @hackathon.avatar
  #     respond_to do |format|
  #       format.html { render action: 'edit' }
  #       format.js { render json: @hackathon.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  private
    def load_hackathon
      @hackathon = load_with_user_name Hackathon
    end
end