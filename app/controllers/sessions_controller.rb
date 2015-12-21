class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:login, :create]

	def login
	end

	def create
    if params["username"] == ENV['DT_USERNAME'] && params["password"] == ENV['DT_PASSWORD']
      session[:authenticated] = true

      redirect_to root_path, notice: "You have successfully logged in."

    else
      render :login
    end
	end

  def destroy
    reset_session
    redirect_to root_path
  end
end
