class SidebarComponent < ViewComponent::Base
  attr_reader :sections

  SIDEBAR_SECTION = Struct.new(:title, :items, keyword_init: true).freeze
  SIDEBAR_ITEM = Struct.new(:name, :path, :icon, keyword_init: true).freeze

  def before_render
    @sections = []
    build_admin_section
    build_projects_section
  end

  private

  def build_admin_section
    @sections << SIDEBAR_SECTION.new(
      title: t("admin", scope: "components.sidebar_component.build_admin_section"),
      items: [
        SIDEBAR_ITEM.new(name: t("projects", scope: "components.sidebar_component.build_admin_section"),
                         path: helpers.projects_path, icon: "journal-text"),
        SIDEBAR_ITEM.new(name: t("new_report", scope: "components.sidebar_component.build_admin_section"),
                         path: helpers.new_report_path, icon: "add"),
        SIDEBAR_ITEM.new(name: t("users", scope: "components.sidebar_component.build_admin_section"),
                         path: helpers.users_path, icon: "person-gear"),
        SIDEBAR_ITEM.new(name: t("regions", scope: "components.sidebar_component.build_admin_section"),
                         path: helpers.regions_path, icon: "compass")
      ]
    )
  end

  def build_projects_section
    items = Project.order(:name).map do |project|
      SIDEBAR_ITEM.new(
        name: project.name,
        path: helpers.project_path(project),
        icon: "folder"
      )
    end

    @sections << SIDEBAR_SECTION.new(
      title: t("projects", scope: "components.sidebar_component.build_projects_section"),
      items:
    )
  end

  def logout_item
    @logout_item ||= SIDEBAR_ITEM.new(name: t("logout", scope: "components.sidebar_component.logout_item"),
                                      path: helpers.logout_path, icon: "box-arrow-left")
  end
end
