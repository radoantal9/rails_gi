class CreateWordDefinitions < ActiveRecord::Migration
  def change
    create_table :word_definitions do |t|
      t.string :word
      t.text :word_definition

      t.timestamps
    end

    add_index :word_definitions, :word
  end
end
