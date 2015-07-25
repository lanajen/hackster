class PromotionsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_promotion, only: [:show, :update]
  layout 'group_shared', only: [:edit, :update, :show]
  respond_to :html

  def show
    title @promotion.name
    meta_desc "Join the promotion #{@promotion.name} on Hackster.io!"
    @project_collections = @promotion.project_collections.includes(:project).includes(project: [:users, :cover_image, :team]).order("project_collections.collectable_id DESC").paginate(page: safe_page_params, per_page: 16)
    @students = @promotion.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('student').map(&:user).select{|u| u.invitation_token.nil? }
    @staffs = @promotion.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles(%w(ta professor)).map(&:user).select{|u| u.invitation_token.nil? }
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
          @promotion = @promotion.decorate
          if old_promotion.user_name != @promotion.user_name
            @refresh = true
          end

          render "groups/promotions/#{self.action_name}"
        end

        track_event 'Updated promotion'
      end
    else
      @promotion.build_avatar unless @promotion.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @promotion.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_promotion
      @group = @promotion = Promotion.includes(:course).where(groups: { user_name: params[:promotion_name] }, courses_groups: { user_name: params[:user_name] }).first!
    end
end