class ModalComponent < ViewComponent::Base
  attr_reader :button_text, :id

  renders_one :modal_content

  def initialize(button_text:, id: "modal")
    super()
    @button_text = button_text
    @id = id
  end
end
