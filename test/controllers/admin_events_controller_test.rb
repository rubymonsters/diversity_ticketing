require 'test_helper'

class AdminEventsControllerTest < ActionController::TestCase
  test 'does not show admin stuff to logged-in non-admins' do
    user = User.create
    sign_in_as(user)

    get :index

    assert_redirected_to root_path
  end

  test 'does show admin stuff to logged-in admins' do
    user = User.create(admin: true)
    sign_in_as(user)

    get :index

    assert_response :success
  end
end
