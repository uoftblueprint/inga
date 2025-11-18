FactoryBot.define do
  factory :subproject do
    sequence(:name) { |n| "Subproject #{n}" }
    description { "Description of the subproject." }
    region
    project
  end
end
