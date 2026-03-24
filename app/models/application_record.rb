class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def to_polymorphic_path
    self
  end
end
