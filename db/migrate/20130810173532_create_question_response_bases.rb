class CreateQuestionResponseBases < ActiveRecord::Migration
  def change
    create_table :question_response_bases do |t|
      t.string   "type"

      t.integer  "user_id"
      t.integer  "question_id"

      t.string   "content_hash"
      t.text     "given_answer"

      # QuestionGradeReport
      t.integer  "quiz_result_id"
      t.float    "score"
      t.text     "correct_answer"
      t.text     "details"

      # QuestionResponse
      t.integer  "question_privacy_cd", :default => 0
      t.string   "title"

      t.timestamps
    end

    add_index "question_response_bases", "type"

    add_index "question_response_bases", "user_id"
    add_index "question_response_bases", "content_hash"
    add_index "question_response_bases", "question_id"

    add_index "question_response_bases", "quiz_result_id"

    add_index "question_response_bases", "question_privacy_cd"
    add_index "question_response_bases", "title"
  end
end
