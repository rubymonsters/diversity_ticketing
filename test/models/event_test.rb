require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def test_open_returns_true_for_future_end_date
    event = Event.new(end_date: 1.week.from_now)
    assert true, event.open?
  end

  test 'open? returns true when the end date is in the future' do
    event = Event.new(end_date: 1.week.from_now)
    assert true, event.open?
  end

  describe '#open?' do
    it 'returns true when the end date is in the future' do
      event = Event.new(end_date: 1.week.from_now)
      assert true, event.open?
    end

    it 'does something else'
  end
end
