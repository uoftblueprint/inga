class Journal < ApplicationRecord
  belongs_to :subproject
  belongs_to :user

  has_many :journal_reports, dependent: :destroy
  has_many :reports, through: :journal_reports

  has_rich_text :markdown_content

  validates :title, presence: true
end
