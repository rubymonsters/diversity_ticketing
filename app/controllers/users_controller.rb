class UsersController < Clearance::UsersController

	def edit
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		if @user.update(user_params)
			redirect_to edit_user_path(@user), notice: "You have successfully updated your user data."
		else
			render :edit
		end
	end

  private

	  def user_params
	    params.require(:user).permit(:email, :password)
	  end
end
