class DockComponent < ViewComponent::Base
  attr_reader :items, :logout_item

  def initialize(items:, logout_item:)
    super()
    @items = items
    @logout_item = logout_item
  end

  private

  def wrapper_classes = "group flex flex-col items-center justify-center gap-1"
  def icon_classes =  "transition-transform duration-150 group-hover:-translate-y-1"
end
