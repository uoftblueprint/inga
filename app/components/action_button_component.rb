class ActionButtonComponent < ViewComponent::Base
  attr_reader :to, :icon, :colour, :method, :confirm, :turbo_stream

  COLOUR_CLASSES = {
    neutral: "btn-neutral",
    primary: "btn-primary",
    secondary: "btn-secondary",
    accent: "btn-accent",
    info: "btn-info",
    success: "btn-success",
    warning: "btn-warning",
    error: "btn-error"
  }.freeze

  def initialize(to:, icon:, colour: :primary, method: :get, confirm: nil, turbo_stream: false, size: :small)
    super()

    @to = to
    @icon = icon
    @colour = colour
    @method = method
    @confirm = confirm
    @turbo_stream = turbo_stream
    @size = size
  end

  def form_data
    { turbo_confirm: @confirm.presence, turbo_stream: (@turbo_stream ? true : nil) }.compact
  end

  def link_data
    { turbo_stream: (@turbo_stream ? true : nil) }.compact
  end

  private

  def small? = @size == :small
  def medium? = @size == :medium
  def large? = @size == :large

  def render_method(&)
    if @method == :get
      link_to(@to, data: link_data, class: css_classes, &)
    else
      button_to(@to, method: @method, form: { data: form_data }, class: css_classes, &)
    end
  end

  def css_classes
    class_names(
      "btn active:btn-active",
      COLOUR_CLASSES[@colour],
      small? && "btn-xs btn-square btn-soft",
      medium? && "btn-sm px-3 py-2 gap-2 font-semibold",
      large? && "btn-md px-4 py-3 gap-2 font-semibold shadow-sm"
    )
  end
end
