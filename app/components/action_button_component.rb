class ActionButtonComponent < ViewComponent::Base
  attr_reader :to, :icon, :colour, :method, :confirm, :turbo_stream

  def initialize(to:, icon:, colour: :primary, method: :get, confirm: nil, turbo_stream: false)
    super()

    @to = to
    @icon = icon
    @colour = colour
    @method = method
    @confirm = confirm
    @turbo_stream = turbo_stream
  end

  def form_data
    { turbo_confirm: @confirm.presence, turbo_stream: (@turbo_stream ? true : nil) }.compact
  end

  def link_data
    { turbo_stream: (@turbo_stream ? true : nil) }.compact
  end

  private

  def css_classes
    class_names("btn btn-#{@colour} btn-soft btn-sm btn-square active:btn-active")
  end
end
