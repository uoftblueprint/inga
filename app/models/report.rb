class Report < ApplicationRecord
  has_many :journal_reports, dependent: :destroy
  has_many :journals, through: :journal_reports

  has_many :aggregated_data, class_name: "AggregatedDatum", dependent: :destroy
end
