class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order('created_at DESC').paginate(:page => params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.skip_confirmation!

    if @user.save
      redirect_to admin_users_path, :notice => 'New user created'
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      redirect_to admin_users_path, :notice => 'User successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, :notice => 'User successfuly deleted'
  end

  def password
    @user = User.find(params[:id])
  end

  def extract
    respond_to do |format|
      format.csv { send_data User.to_csv }
    end
  end
end