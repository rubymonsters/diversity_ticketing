require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
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
	