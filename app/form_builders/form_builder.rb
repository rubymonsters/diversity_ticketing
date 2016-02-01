class FormBuilder < ActionView::Helpers::FormBuilder
  def form_field(field_type, attribute, name, options = {})
    css_classes = options.delete(:class) || []
    css_classes << 'form_field'
    if @object.class.validators_on(attribute).any? { |v| v.kind == :presence }
      css_classes << 'required'
    end

    @template.content_tag(:div, class: css_classes) do
      label(attribute, name) + send(field_type, attribute, objectify_options(options))
    end
  end
end
