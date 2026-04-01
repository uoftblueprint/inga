class SidebarComponent < ViewComponent::Base
  attr_reader :sections

  SIDEBAR_SECTION = Struct.new(:title, :items, keyword_init: true).freeze
  SIDEBAR_ITEM = Struct.new(:name, :path, :icon, keyword_init: true).freeze

  def before_render
    @sections = []

    if admin?
      build_admin_section
      build_reports_section if analyst?
      build_projects_section
    elsif reporter?
      build_reporter_section
      build_reports_section if analyst?
    elsif analyst?
      build_reports_section
    end
  end

  private

  def build_admin_section
    @sections << SIDEBAR_SECTION.new(
      title: t("admin", scope: "components.sidebar_component.build_admin_section"),
      items: [
        SIDEBAR_ITEM.new(name: t("projects", scope: "components.sidebar_component.build_admin_section"),
                         path: helpers.projects_path, icon: "journal-text"),
        SIDEBAR_ITEM.new(name: t("users", scope: "components.sidebar_component.build_admin_section"),
                         path: helpers.users_path, icon: "person-gear"),
        SIDEBAR_ITEM.new(name: t("regions", scope: "components.sidebar_component.build_admin_section"),
                         path: helpers.regions_path, icon: "compass")
      ]
    )
  end

  def build_projects_section
    items = Project.order(updated_at: :desc).limit(5).map do |project|
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

  def build_reporter_section
    @sections << SIDEBAR_SECTION.new(
      title: t("home", scope: "components.sidebar_component.build_reporter_section"),
      items: [
        SIDEBAR_ITEM.new(name: t("home", scope: "components.sidebar_component.build_reporter_section"),
                         path: helpers.reporter_dashboard_path, icon: "house")
      ]
    )
  end

  def build_reports_section
    @sections << SIDEBAR_SECTION.new(
      title: t("reports", scope: "components.sidebar_component.build_reports_section"),
      items: [
        SIDEBAR_ITEM.new(name: t("reports", scope: "components.sidebar_component.build_reports_section"),
                         path: helpers.reports_path, icon: "reports-fill"),
        SIDEBAR_ITEM.new(name: t("create_new_report", scope: "components.sidebar_component.build_reports_section"),
                         path: helpers.new_report_path, icon: "add")
      ]
    )
  end

  def admin?
    helpers.current_user&.has_roles?(:admin)
  end

  def reporter?
    helpers.current_user&.has_roles?(:reporter) && !admin?
  end

  def analyst?
    helpers.current_user&.has_roles?(:analyst)
  end

  def logout_item
    @logout_item ||= SIDEBAR_ITEM.new(name: t("logout", scope: "components.sidebar_component.logout_item"),
                                      path: helpers.logout_path, icon: "box-arrow-left")
  end
end
