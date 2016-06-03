class RemoveIdentifierFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :identifier
  end

  def down
    add_column :questions, :identifier, :string
  end
end
