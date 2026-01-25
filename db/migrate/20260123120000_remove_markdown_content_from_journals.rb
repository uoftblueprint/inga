class RemoveMarkdownContentFromJournals < ActiveRecord::Migration[8.1]
  def change
    remove_column :journals, :markdown_content, :text
  end
end
