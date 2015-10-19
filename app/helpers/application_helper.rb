module ApplicationHelper
  def navbar_link_to(name, url)
    link_to_unless_current(name, url) {
      content_tag(:span, name, class: 'active')
    }
  end
end
