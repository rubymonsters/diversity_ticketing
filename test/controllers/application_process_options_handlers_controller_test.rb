require 'test_helper'

class ApplicationProcessOptionsHandlersControllerTest < ActionController::TestCase
  before do
    @apoh = make_application_process_options_handler
  end

  describe '#update' do
    it 'updates application_process_option selection_by_dt correctly' do
      user = make_user(admin: true)
      sign_in_as(user)

      assert_equal(true, @apoh.selection_by_dt_enabled)

      patch :update, params: { application_process_options_handler: {selection_by_dt_enabled: 0} }
      assert_response :redirect

      @apoh.reload

      assert_equal(false, @apoh.selection_by_dt_enabled)
    end
  end
end
