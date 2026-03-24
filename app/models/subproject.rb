class Subproject < ApplicationRecord
  belongs_to :region
  belongs_to :project

  validates :name, presence: true, uniqueness: { scope: :project_id }

  has_many :log_entries, dependent: :destroy
  has_many :journals, dependent: :destroy

  def to_polymorphic_path
    [project, self]
  end
end
