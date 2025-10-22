require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "has_roles? correctly identifies a user's roles" do
    user = create(:user, :admin)
    assert user.has_roles?(:admin)
    refute user.has_roles?(:reporter)
  end
end
