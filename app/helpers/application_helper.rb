module ApplicationHelper
  def navbar_link_to(name, url, classes = [])
    link_to_unless_current(name, url, class: classes) {
      content_tag(:span, name, class: 'active')
    }
  end

  def span_for_funded(title, funded)
    content_tag(:span, title, class: funded ? 'funded' : 'not-funded')
  end

  def join_messages(messages)
    *head, tail = messages
    [head.join(", "), tail].reject { |s| s.blank? }.join(" and ")
  end

  def pluralize_highlight_count(count, word)
    output = Array.new
    output << "<span class='highlight'>#{count}</span>"

    count == 1 ? output << "#{word}" : output << "#{word.pluralize}"

    output.join(' ').html_safe
  end

  def format_date_range(start_date, end_date)
    if start_date == end_date
      format_date(end_date)
    elsif start_date.mon == end_date.mon
      format_date_range_same_month(start_date, end_date)
    else
      format_date_range_different_month(start_date, end_date)
    end
  end

  def format_date(date)
    date.strftime("%B #{date.mday.ordinalize}, %Y")
  end

  def format_datetime(datetime)
    datetime.strftime("%B #{datetime.mday.ordinalize}, %Y %H:%M:%S %Z")
  end

  def format_date_range_same_month(start_date, end_date)
    start_date.strftime("%B #{start_date.mday.ordinalize}") + " to #{end_date.mday.ordinalize}, #{end_date.year}"
  end

  def format_date_range_different_month(start_date, end_date)
    start_date.strftime("%B #{start_date.mday.ordinalize}") +
      " to " +
      end_date.strftime("%B #{end_date.mday.ordinalize}") +
      ", #{end_date.year}"
  end

  def full_title(page_title = '')
    base_title = "DiversityTickets"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end
