class Subproject < ApplicationRecord
  belongs_to :region
  belongs_to :project

  validates :name, presence: true, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :description, presence: true
  validates :address, presence: true
  has_many :log_entries
  has_many :journals
end
