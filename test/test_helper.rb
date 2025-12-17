ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
Rails.root.glob("test/helpers/**/*.rb").each { |file| require file }

require "rails/test_help"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    include Helpers::AssertStatements

    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def create_logged_in_user
      create(:user).tap do |user|
        post login_url, params: { username: user.username, password: user.password }
      end
    end

    def create_logged_in_admin_user
      create_logged_in_user.tap do |user|
        create(:admin_role, user:)
      end
    end

    def log_out_user
      delete logout_url
    end
  end
end
