class Project < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :subprojects, dependent: :restrict_with_error
  has_many :reports

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end
