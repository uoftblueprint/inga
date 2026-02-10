class JournalReport < ApplicationRecord
  belongs_to :journal
  belongs_to :report

  validates :journal_id, uniqueness: { scope: :report_id }
end
