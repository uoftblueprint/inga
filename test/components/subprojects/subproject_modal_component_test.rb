require "test_helper"
require "view_component/test_case"

module Subprojects
  class SubprojectModalComponentTest < ViewComponent::TestCase
    def setup
      @project = create(:project)
    end

    test "renders the modal button and form" do
      render_inline(SubprojectModalComponent.new(project: @project))

      assert_selector "button", text: I18n.t("projects.show.create_subproject", default: "Create Subproject")
      assert_selector "form"
    end
  end
end
