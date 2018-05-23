require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  describe '#create' do
    it 'redirects back to the homepage when the user is authenticated' do
      user = make_user

      post :create, params: { referer: '/', session: { email: user.email, password: user.password } }

      assert_redirected_to :root
    end

    it 'shows an unauthorized status (401) when the user is not authenticated' do
      user = make_user
      post :create, params: { session: { email: user.email, password: 'wrongpassword' } }

      assert_equal 'Bad email or password.', flash[:alert]
      assert_response :unauthorized
      assert_template 'sessions/new'
    end
  end
end
