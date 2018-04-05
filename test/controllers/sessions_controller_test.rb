require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  describe '#create' do
    it 'redirects back to the homepage when the user is authenticated' do
      user = make_user

      post :create, session: { email: user.email, password: user.password }

      assert_redirected_to :root
    end

    it 'shows an unauthorized response when the user is not authenticated' do
      post :create, session: { email: 'email@test.org' }

      assert_equal 'Bad email or password.', flash[:alert]
      assert_response :unauthorized
      assert_template 'sessions/new'
    end
  end
end
