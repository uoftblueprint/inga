module Users
  class RoleBadgeComponent < ViewComponent::Base
    def initialize(role_name:)
      super()
      @role_name = role_name
    end

    def role_badge_args
      case @role_name.downcase
      when "admin"
        { text: t("users.role_badge_component.roles.admin"), colour: :info }
      when "reporter"
        { text: t("users.role_badge_component.roles.reporter"), colour: :primary }
      when "analyst"
        { text: t("users.role_badge_component.roles.analyst"), colour: :accent }
      else
        { text: t("users.role_badge_component.roles.unknown"), colour: :neutral }
      end
    end
  end
end
