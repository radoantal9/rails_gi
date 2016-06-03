class ConvertGuessAnswersToString < ActiveRecord::Migration
  def up
    QuestionResponse.find_each do |qr|
      if qr.given_answer.has_key?(:answer)
        qr.given_answer['answer'] = qr.given_answer[:answer]
        qr.save!
      end
    end
  end

  def down
    raise 'Unimplemeneted'
  end
end
