FactoryBot.define do
  factory :journal do
    title { "Sample title" }
    markdown_content { "Sample journal content" }

    subproject
    user
  end
end
