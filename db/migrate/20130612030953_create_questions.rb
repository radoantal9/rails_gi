class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :identifier
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
