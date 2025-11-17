FactoryBot.define do
  factory :subproject do
    name { "Test Subproject" }
    description { "Test subproject description" }
    address { "123 Main St" }
    project
    region
  end
end
