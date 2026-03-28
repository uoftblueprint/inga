require "test_helper"

class LogEntryTest < ActiveSupport::TestCase
  setup do
    @project = create(:project, log_schema: { "content" => "text", "verified" => "boolean", "notes" => "text" })
    @subproject = create(:subproject, project: @project)
  end

  test "log entry is not valid if metadata is empty" do
    log_entry = build(:log_entry, subproject: @subproject, metadata: {})

    assert_not log_entry.valid?
    assert_includes log_entry.errors.full_messages,
                    I18n.t("activerecord.errors.models.log_entry.attributes.base.not_empty")
  end

  test "log entry is not valid if metadata contains only nil values" do
    log_entry = build(:log_entry, subproject: @subproject, metadata: { "content" => nil, "verified" => nil })
    assert_not log_entry.valid?
    assert_includes log_entry.errors.full_messages,
                    I18n.t("activerecord.errors.models.log_entry.attributes.base.not_empty")
  end

  test "log entry is valid if metadata contains a boolean false" do
    log_entry = build(:log_entry, subproject: @subproject, metadata: { "verified" => false })
    assert log_entry.valid?
  end
end
