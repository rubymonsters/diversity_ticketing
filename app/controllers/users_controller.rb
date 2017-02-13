class UsersController < Clearance::UsersController
  before_action :ensure_correct_user, only: [:show, :edit, :update]

  def show
    @categorized_user_events = {
      approved: @user.events.approved.upcoming,
      unapproved: @user.events.unapproved.upcoming,
      past: @user.events.past
    }
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: "You have successfully updated your user data."
    else
      render :edit
    end
  end

  private
    def ensure_correct_user
      @user = User.find(params[:id])
      unless @user == current_user
        head :forbidden
      end
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end
end
