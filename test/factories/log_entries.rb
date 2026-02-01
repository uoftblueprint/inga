FactoryBot.define do
  factory :log_entry do
    metadata do
      {
        is_active: true,
        description: "Sample log entry",
        count: 42
      }
    end

    subproject
    user
  end
end
