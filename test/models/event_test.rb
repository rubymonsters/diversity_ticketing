require 'test_helper'

class EventTest < ActiveSupport::TestCase
  describe "#open?" do
    it 'returns true when the end date is in the future' do
      event = Event.new(end_date: 1.week.from_now)
      assert_equal true, event.open?
    end

    it 'returns false when the end date is in the past' do
      event = Event.new(end_date: 1.week.ago)
      assert_equal false, event.open?
    end
  end

  describe "validating organizer_email" do
    it 'should allow a valid email address' do
      event = Event.new(organizer_email: "email@website.de")
      assert_attribute_valid(event, :organizer_email)
    end

    it 'should not allow an invalid email address' do
      event = Event.new(organizer_email: "emailwebsite.de")
      assert_attribute_invalid(event, :organizer_email)
    end
  end
end
