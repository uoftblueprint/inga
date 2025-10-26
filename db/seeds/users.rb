module Seeds
  class Users
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("users", "user_roles")
        seed_users
      end

      private

      def seed_users
        Rails.logger.info "Seeding users..."
        ActiveRecord::Base.transaction do
          admin = User.create!(username: "admin", password: "a")
          super_user = User.create!(username: "super", password: "a")
          logger = User.create!(username: "logger", password: "a")
          analyst = User.create!(username: "analyst", password: "a")

          set_roles(admin, :admin)
          set_roles(logger, :logger)
          set_roles(analyst, :analyst)
          set_roles(super_user, :admin, :logger, :analyst)
        end
      end

      def set_roles(user, *roles)
        roles.each { |role| UserRole.create!(user: user, role: role) }
      end
    end
  end
end
