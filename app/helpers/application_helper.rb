module ApplicationHelper
  def navbar_link_to(name, url)
    link_to_unless_current(name, url) {
      content_tag(:span, name, class: 'active')
    }
  end

  def join_messages(messages)
    *head, tail = messages
    [head.join(", "), tail].reject { |s| s.blank? }.join(" and ")
  end
end
