class LogEntry < ApplicationRecord
  belongs_to :subproject
  belongs_to :user

  validate :not_empty

  private

  def not_empty
    return if metadata.is_a?(Hash) && metadata.values.any?(&:present?)

    errors.add(:base, :not_empty)
  end
end
