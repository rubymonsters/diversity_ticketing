class SessionsController < Clearance::SessionsController

  def create
    @user = authenticate(params)
    request.env['HTTP_REFERER'] = params[:referer]

    sign_in(@user) do |status|
      if status.success?
        redirect_back(fallback_location: root_path)
      else
        flash[:alert] = status.failure_message
        render template: "sessions/new", status: :unauthorized
      end
    end
  end
end
