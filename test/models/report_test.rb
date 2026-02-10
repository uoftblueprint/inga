require "test_helper"

class ReportTest < ActiveSupport::TestCase
  def setup
    @report = create(:report)
  end

  test "can have many journals associated with it" do
    journal1 = create(:journal)
    journal2 = create(:journal)

    @report.journals << journal1
    @report.journals << journal2

    assert_equal 2, @report.journals.count
  end
end
