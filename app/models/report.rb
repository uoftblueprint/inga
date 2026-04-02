class Report < ApplicationRecord
  has_many :journal_reports, dependent: :destroy
  has_many :journals, through: :journal_reports

  has_many :aggregated_data, class_name: "AggregatedDatum", dependent: :destroy

  scope :active, -> { where(active: true) }

  validates :uuid, presence: true, uniqueness: true

  before_validation :ensure_uuid, on: :create

  def to_param
    uuid
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
