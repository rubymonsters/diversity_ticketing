class UsersController < Clearance::UsersController
  before_action :ensure_correct_user, only: [:show, :edit, :update, :applications]

  def show
    @categorized_user_events = {
      approved: @user.events.approved.upcoming,
      unapproved: @user.events.unapproved.upcoming,
      past: @user.events.past
    }
  end

  def create
    @user = user_from_params
    if @user.save
      sign_in @user
      redirect_to root_path
    else
      render template: "users/new"
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: "You have successfully updated your user data."
    elsif user_params[:password] === ''
      flash.now[:error] = "Password is a mandatory field"
      render :edit
    else
      render :edit
    end
  end

  def applications
    @categorized_user_applications = {
      all: @user.applications
    }
  end

  private
    def ensure_correct_user
      @user = User.find(params[:id])
      unless @user == current_user
        head :forbidden
      end
    end

    def user_params
      params.require(:user).permit(:name, :email, :password)
    end

    def user_from_params
      name = user_params.delete(:name)
      email = user_params.delete(:email)
      password = user_params.delete(:password)

      Clearance.configuration.user_model.new(user_params).tap do |user|
        user.name = name
        user.email = email
        user.password = password
      end
    end
end
