Rails.root.glob("db/seeds/**/*.rb").each { |file| require file }

return unless Rails.env.development?

Seeds::Users.run
Seeds::Projects.run
Seeds::LogEntries.run
