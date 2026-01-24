FactoryBot.define do
  factory :journal do
    markdown_content { "Sample journal content" }

    subproject
    user
  end
end
