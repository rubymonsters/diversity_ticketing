require 'csv'

module ReportExporter
  def self.events_report
    CSV.generate do |csv|
      csv << [
        "Event ID",
        "Name",
        "City",
        "Country",
        "Start Date",
        "End Date",
        "Application Process",
        "Number of Tickets",
        "Number of Applications"
      ]

      query = <<-SQL
        SELECT
          e.id "event_id",
          e.name,
          e.city,
          e.country,
          e.start_date,
          e.end_date,
          e.application_process,
          e.number_of_tickets,
          COUNT(a.*) "applications" FROM events e
        LEFT JOIN applications a ON e.id = a.event_id
        WHERE e.approved AND e.deadline < NOW()
        GROUP BY e.id
        ORDER BY e.created_at;
      SQL

      results = ActiveRecord::Base.connection.execute(query).to_a

      results.each do |result|
        csv << [
          result["event_id"],
          result["name"],
          result["city"],
          result["country"],
          result["start_date"],
          result["end_date"],
          result["application_process"],
          result["number_of_tickets"],
          result["applications"]
        ]
      end
    end
  end
end
