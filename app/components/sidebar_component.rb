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
      title: "Admin",
      items: [
        SIDEBAR_ITEM.new(name: "Projects", path: helpers.projects_path, icon: "journal-text"),
        SIDEBAR_ITEM.new(name: "Users", path: helpers.users_path, icon: "person-gear"),
        SIDEBAR_ITEM.new(name: "Regions", path: helpers.regions_path, icon: "compass")
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
      title: "Projects",
      items:
    )
  end

  def logout_item
    @logout_item ||= SIDEBAR_ITEM.new(name: "Logout", path: helpers.logout_path, icon: "box-arrow-left")
  end

  def render? = !current_page?(helpers.login_path)
end
