module ApplicationProcess
  class Choice
    ALLOWED = %w{ selection_by_travis selection_by_organizer application_by_organizer }

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def valid?
      ALLOWED.include?(value)
    end

    def selection_by_travis?
      value == 'selection_by_travis'
    end

    def selection_by_organizer?
      value == 'selection_by_organizer'
    end

    def application_by_organizer?
      value == 'application_by_organizer'
    end
  end

  module Validator
    def self.included(base)
      base.validates_each :application_process do |record, attr, value|
        unless Choice.new(value).valid?
          record.errors.add(attr, 'must be a valid application process')
        end
      end

      base.validates_acceptance_of(:data_protection_confirmation, {
        allow_nil: false,
        if: ->(event) { Choice.new(event.application_process).selection_by_organizer? }
      })

      base.validates :application_link, {
        if: ->(event) {
          choice = Choice.new(event.application_process)
          choice.application_by_organizer?
        },
        presence: true,
        format: { with: /(http|https):\/\/.+\..+/ }
      }

      base.validates :application_link, {
        if: ->(event) {
          choice = Choice.new(event.application_process)
          !choice.application_by_organizer?
        },
        absence: true
      }
    end
  end
end
