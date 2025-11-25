class DefaultFormBuilder < ActionView::Helpers::FormBuilder
  FIELD_CLASSES = {
    email_field: "input",
    file_field: "file-input",
    number_field: "input",
    password_field: "input",
    phone_field: "input",
    search_field: "input",
    textarea: "input",
    text_field: "input"
  }.freeze

  FIELD_CLASSES.each do |method_name, default_class|
    define_method(method_name) do |method, options = {}|
      add_class_to_options(options, default_class)
      super(method, options)
    end
  end

  def checkbox(method, options = {}, checked_value = "1", unchecked_value = "0")
    add_class_to_options(options, "checkbox")
    super
  end

  def collection_checkboxes(method, collection, value_method, text_method, options = {}, html_options = {})
    add_class_to_options(html_options, "checkbox")
    super
  end

  def collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {})
    add_class_to_options(html_options, "radio")
    super
  end

  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    add_class_to_options(html_options, "select")
    super
  end

  def label(method, text = nil, options = {})
    add_class_to_options(options, "label")
    super
  end

  def radio_button(method, tag_value, options = {})
    add_class_to_options(options, "radio")
    super
  end

  def select(method, choices = nil, options = {}, html_options = {})
    add_class_to_options(html_options, "select")
    super
  end

  def submit(value = nil, options = {})
    add_class_to_options(options, "btn btn-neutral")
    super
  end

  private

  def add_class_to_options(options, new_class)
    combined = [options[:class], new_class].compact.join(" ")
    options[:class] = TailwindMerge::Merger.new.merge(combined)
  end
end
