require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  describe '#create' do
    it 'shows an unauthorized response when the user is not authenticated' do
      post :create, session: { email: 'email@test.org' }
      assert_equal 'Bad email or password.', flash[:alert]
      assert_response :unauthorized
      assert_template 'sessions/new'
    end
  end
end
