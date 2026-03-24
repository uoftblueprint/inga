class LogEntry < ApplicationRecord
  belongs_to :subproject
  belongs_to :user

  def to_polymorphic_path
    [subproject.project, subproject, self]
  end
end
