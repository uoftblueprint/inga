FactoryBot.define do
  factory :log_entry do
    metadata do
      {
        content: "Sample log entry"
      }
    end

    subproject
    user
  end
end
