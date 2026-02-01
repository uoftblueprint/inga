FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { "Description of the project." }
    active { true }
    log_schema { { content: "text" } }

    trait :inactive do
      active { false }
    end
  end
end
