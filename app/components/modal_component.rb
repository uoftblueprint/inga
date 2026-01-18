class ModalComponent < ViewComponent::Base
  attr_reader :title

  def initialize(title:)
    super()
    @title = title
  end
end
