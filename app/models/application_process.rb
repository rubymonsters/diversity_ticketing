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
  end

  module Validator
  end
end
