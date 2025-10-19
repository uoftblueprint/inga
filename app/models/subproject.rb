class Subproject < ApplicationRecord
  belongs_to :region
  belongs_to :project

  has_many :log_entries
  has_many :journals
end
