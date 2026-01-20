require "test_helper"

class ProjectAttributesControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_logged_in_admin_user
    @project = create(:project)
  end

  [
    { route: "edit", method: :get, url_helper: :edit_project_attributes_schema_path },
    { route: "update", method: :patch, url_helper: :project_attributes_schema_path }
  ].each do |hash|
    test "##{hash[:route]} redirects to login route when a user is not authenticated" do
      log_out_user

      public_send(hash[:method], public_send(hash[:url_helper], @project))
      assert_response :redirect
      assert_redirected_to login_path
    end

    test "##{hash[:route]} redirects to root route when a user is not authorized" do
      create_logged_in_user

      public_send(hash[:method], public_send(hash[:url_helper], @project))
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  [
    { route: "edit", method: :get, url_helper: :edit_project_attributes_schema_path }
  ].each do |hash|
    test "##{hash[:route]} renders successfully when a user is an admin" do
      public_send(hash[:method], public_send(hash[:url_helper], @project))
      assert_response :success
    end
  end

  test "#update successfully updates the project log schema" do
    patch project_attributes_schema_path(@project), params: {
      project: {
        log_attributes: [{ title: "temperature", type: "numerical" }, { title: "location", type: "text" }]
      }
    }

    assert_redirected_to project_path(@project)

    schema = @project.reload.log_schema
    assert_equal "numerical", schema["temperature"]
    assert_equal "text", schema["location"]
  end

  test "#update fails with invalid log schema" do
    patch project_attributes_schema_path(@project), params: {
      project: {
        log_attributes: [{ title: "bad", type: "invalid_type" }]
      }
    }

    assert_response :unprocessable_entity
  end
end
