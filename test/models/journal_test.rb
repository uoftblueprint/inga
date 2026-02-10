require "test_helper"

class JournalTest < ActiveSupport::TestCase
  def setup
    @journal = create(:journal)
  end

  test "can have many reports associated with it" do
    report1 = create(:report)
    report2 = create(:report)

    @journal.reports << report1
    @journal.reports << report2

    assert_equal 2, @journal.reports.count
  end
end
