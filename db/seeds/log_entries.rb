module Seeds
  class LogEntries
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("log_entries")
        seed_log_entries
      end

      private

      def seed_log_entries
        puts "Seeding log entries..."

        user = User.first
        subprojects = Subproject.all

        if user.nil? || subprojects.empty?
          puts "Skipping log entries: No users or subprojects found."
          return
        end

        logs = []

        subprojects.each do |subproject|
          logs << {
            user: user,
            subproject: subproject,
            metadata: {
              "metric_value" => 12.6,
              "verified" => false,
              "notes" => "Log entry 1 for #{subproject.name}"
            }
          }

          logs << {
            user: user,
            subproject: subproject,
            metadata: {
              "metric_value" => 17.8,
              "verified" => true,
              "notes" => "Log entry 2 for #{subproject.name}"
            }
          }
        end

        LogEntry.create!(logs)
      end
    end
  end
end
