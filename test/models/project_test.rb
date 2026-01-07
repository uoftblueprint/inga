require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "#add_log_attribute adds a new attribute to the log schema" do
    project = create(:project)
    project.add_log_attribute("temperature", "numerical")
    assert_equal({ "temperature" => "numerical" }, project.log_schema)
  end

  test "#remove_log_attribute removes an attribute from the log schema" do
    project = create(:project, log_schema: { "humidity" => "numerical", "status" => "text" })
    project.remove_log_attribute("humidity")
    assert_equal({ "status" => "text" }, project.log_schema)
  end

  test "invalid log schema raises validation error" do
    project = build(:project, log_schema: { "invalid_attr" => "unsupported_type" })
    assert_not_predicate project, :valid?
  end
end
