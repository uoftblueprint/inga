class Report < ApplicationRecord
  belongs_to :project

  has_many :snapshots
end
