require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  # PUT update
  # To do: complete this for editing the password as well
	test "user can edit their data" do
    user = User.create(email: "la@le.lu", password: "123456")
    sign_in_as(user)
		
		put :update, id: user.id, user: { email: "cool@email.add" }
		user.reload

		assert_equal user.email, "cool@email.add"
		assert_redirected_to user_path(user)
	end

	# # This throws an error because the edit user template is still missing
	# test "no redirection if update fails" do
	# 	user = User.create(email: "ta@da.aa", password: "654321")
	# 	sign_in_as(user)

	# 	put :update, id: user.id, user: { email: "" }
	# 	user.reload

	# 	assert_response :success
	# end
end
