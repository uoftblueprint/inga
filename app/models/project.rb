class Project < ApplicationRecord
  attribute :log_schema, :json, default: -> { {} }

  validates :name, presence: true, uniqueness: true
  validate :log_schema_shape, if: :log_schema_changed?

  has_many :subprojects, dependent: :destroy

  scope :active, -> { where(active: true) }

  VALID_LOG_SCHEMA_TYPES = %w[numerical boolean text].freeze

  def add_log_attribute(name, type)
    schema = log_schema.dup
    schema[name] = type
    update!(log_schema: schema)
  end

  def replace_log_attributes(*attributes)
    schema = {}
    attributes.each do |attr|
      schema[attr[:title]] = attr[:type]
    end
    update(log_schema: schema)
  end

  def remove_log_attribute(name)
    schema = log_schema.dup
    schema.delete(name)
    update!(log_schema: schema)
  end

  private

  def log_schema_shape
    log_schema.each do |key, value|
      unless VALID_LOG_SCHEMA_TYPES.include?(value)
        errors.add(:log_schema, "Invalid log schema: #{key} has invalid type #{value}")
      end
    end
  end
end
