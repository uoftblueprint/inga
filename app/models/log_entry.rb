class LogEntry < ApplicationRecord
  belongs_to :subproject
  belongs_to :user

  validates :datetime, presence: true

  validate :metadata_matches_log_schema

  private

  def metadata_matches_log_schema
    return if metadata.blank?

    schema = subproject.project.log_schema
    return if schema.blank?

    extra_keys = metadata.keys - schema.keys
    errors.add(:metadata, "contains unexpected fields: #{extra_keys.join(', ')}") if extra_keys.any?

    metadata.each do |key, value|
      next unless schema.key?(key)

      case schema[key]
      when "numerical"
        errors.add(:metadata, "#{key} must be a number") unless value.is_a?(Numeric)
      when "boolean"
        errors.add(:metadata, "#{key} must be true or false") unless [true, false].include?(value)
      when "text"
        errors.add(:metadata, "#{key} must be text") unless value.is_a?(String)
      end
    end
  end
end
