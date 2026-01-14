require "test_helper"

module Projects
  class ProjectModalComponentTest < ViewComponent::TestCase
    def test_renders_modal_and_form
      project = Project.new
      render_inline(Projects::ProjectModalComponent.new(project: project, title: "Create project",
                                                        id: "create_project_modal"))

      assert_selector "button", text: /Create Project/i
      assert_selector "dialog#create_project_modal"
      assert_selector "input[name='project[name]']"
      assert_selector "textarea[name='project[description]']"
    end
  end
end
