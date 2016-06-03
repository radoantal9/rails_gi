class ActsAsCommentableWithThreadingMigration < ActiveRecord::Migration
  def change
    create_table :comments, force: true do |t|
      t.references :commentable, polymorphic: true, index: true, null: false
      t.references :user, index: true

      t.references :parent, index: true
      t.integer :lft
      t.integer :rgt

      t.text :comment_subject
      t.text :comment_body

      t.timestamps
    end

    add_index :comments, :lft
    add_index :comments, :rgt
    add_index :comments, :created_at
  end
end
