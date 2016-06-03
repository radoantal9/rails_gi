class CreateQuizResults < ActiveRecord::Migration
  def change
    create_table :quiz_results do |t|
      t.integer :user_id
      t.integer :quiz_id

      t.timestamps
    end
  end
end
