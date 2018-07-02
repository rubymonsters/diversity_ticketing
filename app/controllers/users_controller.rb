require "report_exporter"

class UsersController < Clearance::UsersController
  before_action :ensure_correct_user, only: [:show, :edit, :update, :destroy, :applications, :confirm_delete, :delete_account]

  def show
    @categorized_user_events = {
      approved: @user.events.approved.upcoming,
      unapproved: @user.events.unapproved.upcoming,
      past: @user.events.past
    }
    render "users/events"
  end

  def create
    @user = user_from_params
    if @user.save
      sign_in @user
      unless params[:referer].include?('continue_as_guest')
        redirect_to root_path
      else
        redirect_to new_event_application_path(params[:event_id])
      end
    else
      render template: "users/new"
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.csv { send_data ReportExporter.user_data(@user), filename: "user_data_#{DateTime.now.strftime("%F")}.csv" }
    end
  end

  def update
    if user_params[:password] === ''
      @user.update(user_params)
      flash.now[:error] = "Password is a mandatory field"
      render :edit
    elsif @user.authenticated?(params[:user][:password])
      if @user.update(user_params)
        if user_params[:new_password] != ''
          @user.update_attributes(password: user_params[:new_password])
        end
        redirect_to edit_user_path(@user), notice: "You have successfully updated your user data."
      else
        render :edit
      end
    else
      flash.now[:error] = "Incorrect password"
      render :edit
    end
  end

  def destroy
    if user_params[:password] === ''
      @user.update(user_params)
      flash.now[:error] = "Password is a mandatory field"
      render :delete_account
    elsif @user.authenticated?(params[:user][:password])
      if @user.destroy
        flash[:alert] = "Your Account has been deleted successfully."
        redirect_to root_path
      else
        render :delete_account
      end
    else
      flash.now[:error] = "Incorrect password"
      render :delete_account
    end
  end

  def confirm_delete
    render :confirm_delete
  end

  def delete_account
    render :delete_account
  end

  def applications
    @categorized_user_applications = {
      submitted: @user.applications.submitted,
      drafts: @user.applications.drafts,
    }
  end

  private
    def ensure_correct_user
      @user = User.find(params[:id])
      unless @user == current_user
        redirect_to root_path, alert: "We're sorry. You don't have permission to access this page."
      end
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :new_password,
        :country, :country_email_notifications, :tag_email_notifications,
        { :tag_ids => [] }, tags_attributes: [:id, :name, :category_id])
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
