class LogEntry < ApplicationRecord
  belongs_to :subproject
  belongs_to :user

  validate :at_least_one_metadata_field_present

  private

  def at_least_one_metadata_field_present
    return if metadata.is_a?(Hash) && metadata.values.any?(&:present?)

    errors.add(:base, "At least one field must be filled in before saving.")
  end
end
