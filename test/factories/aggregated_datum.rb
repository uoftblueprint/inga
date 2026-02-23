FactoryBot.define do
  factory :aggregated_datum do
    additional_text { "Sample additional text" }
    value { 10 }

    report
  end
end
