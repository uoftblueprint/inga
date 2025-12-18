module Users
  class FormComponent < ViewComponent::Base
    def initialize(user:)
      super()
      @user = user
    end
  end
end
