class IconComponent < ViewComponent::Base
  erb_template <<-ERB
    <%= helpers.inline_svg_tag "icons/\#{@icon}.svg", size: size, class: @classes %>
  ERB

  SIZE_MAP = { xs: "12", sm: "16", md: "24", lg: "32", xl: "48" }.freeze

  def initialize(icon:, size: :sm, classes: "")
    super()
    @icon = icon
    @size = size
    @classes = classes
  end

  private

  def size
    SIZE_MAP[@size] || @size.to_s
  end
end
