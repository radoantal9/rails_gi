class CreateQuizzes < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
      t.string :identifier
      t.text :description_private
      t.text :instructions

      t.timestamps
    end
  end
end
