FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { "Description of the project." }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
