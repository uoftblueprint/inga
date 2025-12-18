module Helpers
  module AssertStatements
    def assert_flashed(type)
      assert_not_nil flash[type], "Expected flash[:#{type}] to be set"
    end
  end
end
