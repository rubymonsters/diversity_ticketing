require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "user cannot edit anyone else's data" do
    user1 = make_user(email: "a@example.org")
    user2 = make_user(email: "b@example.org")
    sign_in_as(user1)

    put :update, id: user2.id, user: {email: "c@example.org"}

    user2.reload

    assert_equal "b@example.org", user2.email
    assert_response :forbidden
  end

  test "anonymous user cannot edit anyone else's data" do
    user = make_user(email: "a@example.org")

    put :update, id: user.id, user: {email: "b@example.org"}

    user.reload

    assert_equal "a@example.org", user.email
    assert_redirected_to sign_in_url
  end
  
  # PUT update
  test "user can edit their data" do
    user = make_user(email: "la@le.lu")
    sign_in_as(user)
    
    put :update, id: user.id, user: { email: "cool@email.add", password: "654321" }
    user.reload

    assert_equal user.email, "cool@email.add"
    assert_redirected_to edit_user_path(user)
  end

  test "re-renders edit form if user attributes are invalid" do
    user = make_user(email: "ta@da.aa")
    sign_in_as(user)

    put :update, id: user.id, user: { email: "" }
    user.reload

    assert_equal user.email, "ta@da.aa"
    assert_response :success
  end
end
  