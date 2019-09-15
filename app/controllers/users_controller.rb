require "report_exporter"

class UsersController < Clearance::UsersController
  before_action :ensure_correct_user, except: [:new, :create]

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
    if (user_params[:new_password] != '') || (user_params[:email] != @user.email)
      update_protected_params
    else
      @user.password_optional = true
      if @user.update(user_params)
        redirect_to edit_user_path(@user), notice: t('.update_success')
      end
    end
  end

  def destroy
    if @user.authenticated?(params[:user][:password])
      @user.destroy
      flash[:alert] = t('.account_deleted')
      redirect_to root_path
    else
      if user_params[:password] === ''
        message = t('.password_mandatory')
      else
        message = t('.password_incorrect')
      end
      flash.now[:error] = message
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
        redirect_to root_path, alert: t('.no_permission')
      end
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :new_password, :locale, :event_id,
        :country, :country_email_notifications, :tag_email_notifications, :privacy_policy_agreement,
        :capacity_email_notifications, { :tag_ids => [] },
        tags_attributes: [:id, :name, :category_id])
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

    def update_protected_params
      if @user.authenticated?(user_params[:password])
        if @user.update_attributes(user_params)
          @user.update_attributes(password: user_params[:new_password]) if user_params[:new_password] != ''
          redirect_to edit_user_path(@user), notice: t('.update_success')
        end
      else
        if user_params[:password] === ''
          message = t('.password_mandatory')
        else
          message = t('.password_incorrect')
        end
        flash.now[:error] = message
        render :edit
      end
    end
end
