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

  test "#replace_log_attributes replaces the entire log schema" do
    project = create(:project, log_schema: { "old_attr" => "text" })
    project.replace_log_attributes({ name: "new_attr1", type: "numerical" }, { name: "new_attr2", type: "text" })
    assert_equal({ "new_attr1" => "numerical", "new_attr2" => "text" }, project.log_schema)
  end

  test "invalid log schema raises validation error" do
    project = build(:project, log_schema: { "invalid_attr" => "unsupported_type" })
    assert_not_predicate project, :valid?
  end
end
