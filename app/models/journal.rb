class Journal < ApplicationRecord
  belongs_to :subproject
  belongs_to :user

  has_rich_text :markdown_content
end
