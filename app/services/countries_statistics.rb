class CountriesStatistics
  def initialize(events)
    @events = events
  end

  def to_json
    countries.each_with_object({}) do |country, memo|
      next if key(country).nil?
      memo[key(country)] = [events_count(country), tickets_count(country)]
    end.to_json
  end

  def country_rank
    countries.each_with_object({}) do |country, memo|
      next if country.nil?
      memo[country] = events_count(country)
    end.sort_by { |k, v| -v }
  end

  private

  def key(country)
    key = CS.countries.key(country)
    return if key.nil?

    IsoCountryCodes.find(key).alpha3
  end

  def countries
    @events.pluck(:country).compact.uniq
  end

  def events_count(country)
    @events.pluck(:country).compact.count(country)
  end

  def tickets_count(country)
    @events.where(country: country).sum(:number_of_tickets)
  end
end
