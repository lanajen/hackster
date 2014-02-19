class PromotionsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_promotion, only: [:show, :update]
  layout 'promotion', only: [:edit, :update, :show]
  respond_to :html

  def show
    authorize! :read, @promotion
    title "#{@promotion.course.name} #{@promotion.name}"
    meta_desc "Join the promotion #{@promotion.name} on Hackster.io!"
    # @broadcasts = @promotion.broadcasts.limit 20
    @projects = @promotion.projects.order(assignment_id: :desc)
    @students = @promotion.members.invitation_accepted_or_not_invited.with_group_roles('student').map(&:user).select{|u| u.invitation_token.nil? }
    @staffs = @promotion.members.invitation_accepted_or_not_invited.with_group_roles('staff').map(&:user).select{|u| u.invitation_token.nil? }
    @assignments = @promotion.assignments

    render "groups/promotions/#{self.action_name}"
  end

  def new
    authorize! :create, Promotion
    title "Create a new promotion"
    @promotion = Promotion.new

    render "groups/promotions/#{self.action_name}"
  end

  def create
    @promotion = Promotion.new(params[:promotion])
    authorize! :create, @promotion

    admin = @promotion.members.new(user_id: current_user.id)
    @promotion.private = true

    if @promotion.save
      admin.update_attribute :permission_action, 'manage'
      flash[:notice] = "Welcome to #{@promotion.class.name} #{@promotion.name}!"
      respond_with @promotion
    else
      render "groups/promotions/new"
    end
  end

  def edit
    @promotion = Promotion.find(params[:id])
    authorize! :update, @promotion
    @promotion.build_avatar unless @promotion.avatar

    render "groups/promotions/#{self.action_name}"
  end

  def update
    authorize! :update, @promotion
    old_promotion = @promotion.dup

    if @promotion.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @promotion, notice: 'Profile updated.' }
        format.js do
          @promotion.avatar = nil unless @promotion.avatar.try(:file_url)
          @promotion = @promotion.decorate
          # if old_promotion.interest_tags_string != @promotion.interest_tags_string or old_promotion.skill_tags_string != @promotion.skill_tags_string
          #   @refresh = true
          # end

          render "groups/promotions/#{self.action_name}"
        end

        track_event 'Updated promotion'
      end
    else
      @promotion.build_avatar unless @promotion.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_promotion
      @promotion = Promotion.includes(:course).where(groups: { user_name: params[:promotion_name] }, courses_groups: { user_name: params[:user_name] }).first!
    end
end