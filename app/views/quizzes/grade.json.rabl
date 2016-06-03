object @quiz_result

node (:score) { |quiz_result| quiz_result.score }

child(:question_grade_reports => :q) do
    attribute :question_id => :qid
    child :question do
      attribute :question_type
    end
    attribute :score
    attribute :details
    attribute :correct_answer
    attribute :given_answer
end