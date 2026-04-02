class SidebarComponent < ViewComponent::Base
  attr_reader :sections, :mobile_dock_items

  SIDEBAR_SECTION = Struct.new(:title, :items, :kind, keyword_init: true).freeze
  SIDEBAR_ITEM = Struct.new(:name, :path, :icon, keyword_init: true).freeze

  def before_render
    @sections = []
    @mobile_dock_items = []

    if helpers.admin?
      build_admin_section
      build_reports_section if helpers.analyst?
      build_projects_section
      @mobile_dock_items = admin_items
    elsif helpers.reporter?
      build_reporter_section
      build_reports_section if helpers.analyst?
      @mobile_dock_items = reporter_items
    elsif helpers.analyst?
      build_reports_section
      @mobile_dock_items = reports_items
    end
  end

  private

  def build_admin_section
    @sections << SIDEBAR_SECTION.new(
      title: t("admin", scope: "components.sidebar_component.build_admin_section"),
      items: admin_items,
      kind: :admin
    )
  end

  def build_projects_section
    @sections << SIDEBAR_SECTION.new(
      title: t("projects", scope: "components.sidebar_component.build_projects_section"),
      items: projects_items,
      kind: :projects
    )
  end

  def build_reporter_section
    @sections << SIDEBAR_SECTION.new(
      title: t("home", scope: "components.sidebar_component.build_reporter_section"),
      items: reporter_items,
      kind: :reporter
    )
  end

  def build_reports_section
    @sections << SIDEBAR_SECTION.new(
      title: t("reports", scope: "components.sidebar_component.build_reports_section"),
      items: reports_items,
      kind: :reports
    )
  end

  def admin_items
    [
      SIDEBAR_ITEM.new(name: t("projects", scope: "components.sidebar_component.build_admin_section"),
                       path: helpers.projects_path, icon: "journal-text"),
      SIDEBAR_ITEM.new(name: t("users", scope: "components.sidebar_component.build_admin_section"),
                       path: helpers.users_path, icon: "person-gear"),
      SIDEBAR_ITEM.new(name: t("regions", scope: "components.sidebar_component.build_admin_section"),
                       path: helpers.regions_path, icon: "compass")
    ]
  end

  def projects_items
    Project.order(updated_at: :desc).limit(5).map do |project|
      SIDEBAR_ITEM.new(
        name: project.name,
        path: helpers.project_path(project),
        icon: "folder"
      )
    end
  end

  def reporter_items
    [
      SIDEBAR_ITEM.new(name: t("home", scope: "components.sidebar_component.build_reporter_section"),
                       path: helpers.root_path, icon: "house")
    ]
  end

  def reports_items
    [
      SIDEBAR_ITEM.new(name: t("reports", scope: "components.sidebar_component.build_reports_section"),
                       path: helpers.reports_path, icon: "reports-fill"),
      SIDEBAR_ITEM.new(name: t("create_new_report", scope: "components.sidebar_component.build_reports_section"),
                       path: helpers.new_report_path, icon: "add")
    ]
  end

  def section_classes(section)
    return "[@media(max-height:900px)]:hidden" if section.kind == :projects

    ""
  end

  def logout_item
    @logout_item ||= SIDEBAR_ITEM.new(name: t("logout", scope: "components.sidebar_component.logout_item"),
                                      path: helpers.logout_path, icon: "box-arrow-left")
  end
end
