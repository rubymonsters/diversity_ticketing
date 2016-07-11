require 'test_helper'

class ApplicationProcessTest < ActiveSupport::TestCase
  describe 'handling application process' do
    it 'is valid if its value is allowed' do
      choice = ApplicationProcess::Choice.new('selection_by_organizer')

      assert_equal true, choice.valid?
    end

    it 'is not valid if its value is not allowed' do
      choice = ApplicationProcess::Choice.new('random value')

      assert_equal false, choice.valid?
    end

    it 'reports it is a selection by travis event' do
      choice = ApplicationProcess::Choice.new('selection_by_travis')

      assert choice.selection_by_travis?
    end

    it 'reports it is not an application by organizer event' do
      choice = ApplicationProcess::Choice.new('selection_by_travis')

      assert !choice.application_by_organizer?      
    end
  end
end
