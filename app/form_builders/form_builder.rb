class FormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::CaptureHelper

  def form_field(field_type, attribute, name, options = {})
    class_option = options.delete(:class)
    t = @template

    t.content_tag(:div, class: css_classes(class_option, attribute)) do
      t.capture do
        t.concat label(attribute, name)
        t.concat send(field_type, attribute, objectify_options(options))
      end
    end
  end

  def image_upload_field(attribute, name, options = {})
    class_option = options.delete(:class)
    image_name = options.delete(:image_name)
    t = @template

    t.content_tag(:div, class: css_classes(class_option, attribute)) do
      t.capture do
        t.concat label(attribute, name)
        t.concat(t.content_tag(:p) {
          t.image_tag(image_name, class: "event-logo")
        })
        t.concat file_field(attribute, objectify_options(options))
      end
    end
  end

  def css_classes(class_option, attribute)
    classes = class_option || []
    classes << 'form_field'
    if @object.class.validators_on(attribute).any? { |v| v.kind == :presence }
      classes << 'required'
    end
    classes
  end
end
