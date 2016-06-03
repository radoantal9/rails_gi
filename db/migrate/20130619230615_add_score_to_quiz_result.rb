class AddScoreToQuizResult < ActiveRecord::Migration
  def change
    add_column :quiz_results, :score, :float
  end
end
