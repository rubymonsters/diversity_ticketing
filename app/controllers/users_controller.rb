class UsersController < Clearance::UsersController

	def edit

	end

	def update
		@user = User.find(params[:id])
		if @user.update(user_params)
			redirect_to user_path, notice: "You have successfully updated your user data."
		else
			render :edit
		end
	end
end
