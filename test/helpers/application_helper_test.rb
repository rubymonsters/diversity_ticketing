require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
  include ApplicationHelper

  describe "format_date" do
    it 'returns formatted date for 2016-10-08' do
      assert_equal "October 8th, 2016", format_date("2016-10-08".to_date)
    end
  end

  describe "format_date_range" do
    it 'returns formatted date for same start and end date' do
      assert_equal "October 8th, 2016", format_date_range("2016-10-08".to_date, "2016-10-08".to_date)
    end

    it 'returns formatted date for date range (e.g. start and end date)' do
      assert_equal "October 8th to 12th, 2016", format_date_range("2016-10-08".to_date, "2016-10-12".to_date)
      assert_equal "October 8th to November 12th, 2016", format_date_range("2016-10-08".to_date, "2016-11-12".to_date)
    end
  end
end
