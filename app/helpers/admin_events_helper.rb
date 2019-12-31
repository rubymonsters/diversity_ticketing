module AdminEventsHelper
  def download_csv_link(event)
    link_to 'Download CSV', admin_event_path(id: event.id, format: :csv), class: "btn btn-save", title: 'Download Data'
  end
end
