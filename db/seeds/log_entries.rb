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
        verified_values = [false, true]

        subprojects.cycle(2) do |subproject|
          logs << {
            user_id: user.id,
            subproject_id: subproject.id,
            created_at: Faker::Time.between(from: 30.days.ago, to: Time.current),
            metadata: {
              "metric_value" => rand(10.0..100.0).round(2),
              "verified" => verified_values.sample,
              "notes" => Faker::Lorem.sentence(word_count: 8)
            }
          }
        end

        LogEntry.insert_all(logs) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
