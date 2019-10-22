module AdminEventsHelper
  def download_csv_link(event)
    link_to t('.download_csv'), admin_event_path(id: event.id, format: :csv), class: "btn btn-save", title: t('.download_data')
  end
end
