require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  describe '#create' do
    it 'redirects back to the homepage when the user is authenticated' do
      user = make_user

      post :create, params: { referer: '/', session: { email: user.email, password: user.password } }

      assert_redirected_to 'http://test.host/'
    end

    it 'shows an unauthorized status (401) when the user is not authenticated' do
      user = make_user
      post :create, params: { session: { email: user.email, password: 'wrongpassword' } }

      assert_equal 'Bad email or password.', flash[:alert]
      assert_response :unauthorized
      assert_template 'sessions/new'
    end

    it 'redirects to sign up if the email was not included in the request' do
      user = make_user
      post :create, params: { session: { password: user.password } }

      assert_equal "Account not found, please register first", flash[:alert]
      assert_redirected_to sign_up_path
    end

    it 'redirects to new_password if the current_password is not encrypted' do
      user = make_user
      user.update_attributes(encrypted_password: "x")
      user.reload

      post :create, params: { session: { email: user.email, password: user.password } }

      assert_equal "Due to a security update from our side we kindly ask you to reset your password.", flash[:info]
      assert_redirected_to new_password_path
    end
  end
end
