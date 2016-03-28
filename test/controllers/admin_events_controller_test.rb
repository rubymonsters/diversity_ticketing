require 'test_helper'

class AdminEventsControllerTest < ActionController::TestCase
  test 'protect admin index from anonymous visitors, redirects to sign in' do
    get :index

    assert_redirected_to sign_in_path
  end

  test 'protect admin index from logged-in non-admins, redirects to root' do
    user = User.create
    sign_in_as(user)

    get :index

    assert_redirected_to root_path
  end

  test 'shows admin index to logged-in admins' do
    user = User.create(admin: true)
    sign_in_as(user)

    get :index

    assert_response :success
  end
end
