class AddTitleToContentPage < ActiveRecord::Migration
  def change
    add_column :content_pages, :title, :string
  end
end
