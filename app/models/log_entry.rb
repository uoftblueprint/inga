class LogEntry < ApplicationRecord
  belongs_to :subproject
  belongs_to :user

  validate :not_empty

  private

  def not_empty
    return if metadata.is_a?(Hash) && metadata.values.any?(&:present?)

    # i18n-tasks-use t('activerecord.errors.models.log_entry.attributes.base.not_empty')
    errors.add(:base, :not_empty)
  end
end
