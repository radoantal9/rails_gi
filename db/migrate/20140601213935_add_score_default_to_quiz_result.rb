class AddScoreDefaultToQuizResult < ActiveRecord::Migration
  def up
    change_column :quiz_results, :score, :float, default: 0
    QuizResult.update_scores
  end

  def down
  end
end
