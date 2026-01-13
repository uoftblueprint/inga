class BadgeComponent < ViewComponent::Base
  attr_reader :text

  COLOURS = %i[neutral primary secondary accent info success warning error].freeze
  SIZES = %i[xs sm md lg xl].freeze
  STYLES = %i[solid soft outline dash ghost].freeze

  COLOUR_CLASSES = {
    neutral: "badge-neutral",
    primary: "badge-primary",
    secondary: "badge-secondary",
    accent: "badge-accent",
    info: "badge-info",
    success: "badge-success",
    warning: "badge-warning",
    error: "badge-error"
  }.freeze

  SIZE_CLASSES = {
    xs: "badge-xs",
    sm: "badge-sm",
    md: "badge-md",
    lg: "badge-lg",
    xl: "badge-xl"
  }.freeze

  STYLE_CLASSES = {
    solid: nil,
    soft: "badge-soft",
    outline: "badge-outline",
    dash: "badge-dash",
    ghost: "badge-ghost"
  }.freeze

  private_constant :COLOUR_CLASSES, :SIZE_CLASSES, :STYLE_CLASSES

  def initialize(text:, colour: :neutral, size: :md, style: :solid, html_classes: "")
    super()

    @text = text

    raise ArgumentError, "Invalid colour" unless COLOURS.include?(colour)
    raise ArgumentError, "Invalid size" unless SIZES.include?(size)
    raise ArgumentError, "Invalid style" unless STYLES.include?(style)

    @colour = colour
    @size = size
    @style = style
    @html_classes = html_classes
  end

  private

  def css_classes
    class_names(
      "px-2 badge",
      SIZE_CLASSES[@size],
      STYLE_CLASSES[@style],
      (COLOUR_CLASSES[@colour] unless @style == :ghost),
      @html_classes
    )
  end
end
