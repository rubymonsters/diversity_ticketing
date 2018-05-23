class SessionsController < Clearance::SessionsController

  def create
    if User.find_by(email:params[:session][:email]).nil?
      redirect_to sign_up_path, flash: { :alert => "Account not found, please register first"}

    elsif User.find_by(email: params[:session][:email]).encrypted_password == 'x'
      redirect_to new_password_path, flash: { :info => "Due to a security update from our side we kindly ask you to reset your password." }

    else @user = authenticate(params)

      sign_in(@user) do |status|

        if status.success?
            redirect_to params[:referer]
        else
          flash.now[:alert] = status.failure_message
          render template: "sessions/new", status: :unauthorized
        end
      end
    end
  end
end
