class BadgeComponent < ViewComponent::Base
  attr_reader :text

  COLOURS = %i[neutral primary secondary accent info success warning error].freeze
  SIZES = %i[xs sm md lg xl].freeze
  STYLES = %i[solid soft outline dash ghost].freeze

  def initialize(text:, colour: :neutral, size: :md, style: :solid)
    super()

    @text = text

    raise ArgumentError, "Invalid colour" unless COLOURS.include?(colour)
    raise ArgumentError, "Invalid size" unless SIZES.include?(size)
    raise ArgumentError, "Invalid style" unless STYLES.include?(style)

    @colour = colour
    @size = size
    @style = style
  end

  private

  def css_classes
    classes = ["px-2 badge", "badge-#{@size}"]
    case @style
    when :solid
      classes << "badge-#{@colour}"
    when :soft
      classes << "badge-soft" << "badge-#{@colour}"
    when :outline
      classes << "badge-outline" << "badge-#{@colour}"
    when :dash
      classes << "badge-dash" << "badge-#{@colour}"
    when :ghost
      classes << "badge-ghost"
    end
    classes.join(" ")
  end
end
