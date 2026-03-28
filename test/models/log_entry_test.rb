require "test_helper"

class LogEntryTest < ActiveSupport::TestCase
  test "log entry is not valid if metadata is empty" do
    log_entry = build(:log_entry, metadata: {})

    assert_not log_entry.valid?
    assert_includes log_entry.errors.full_messages,
                    I18n.t("activerecord.errors.models.log_entry.attributes.base.not_empty")
  end
end
