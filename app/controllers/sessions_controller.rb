class SessionsController < Clearance::SessionsController

  def create
    if params[:passcode] && User.find_by(email: params[:session][:email]).encrypted_password === 'x'
      redirect_to  new_password_path, flash: { :info => "Due to a security update from our side we kindly ask you to reset your password." }

    else @user = authenticate(params)

      sign_in(@user) do |status|

        if status.success?
            redirect_to params[:referer]
        else
          flash[:alert] = status.failure_message
          render template: "sessions/new", status: :unauthorized
        end
      end
    end
  end
end
