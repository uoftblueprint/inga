Dir[Rails.root.join("db", "seeds", "**", "*.rb")].each { |file| require file }

return unless Rails.env.development?

Seeds::Users.run
Seeds::Projects.run
