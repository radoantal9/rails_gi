class ScoreHelper

  ###########
  def multiple_choice(given_answer_array, correct_answer_array, total_number_of_choices)

    # We have a blank answer, 0 score default for blank, no freebee score for implicitly blank options
    if given_answer_array.empty?
      return 0.0
    end

    # We will be giving 0 score to "all options checked" answers, i know, its a penalty but
    # we checks have to be used wisely, not to fish for answers
    if given_answer_array.length == total_number_of_choices
      return 0.0
    end


    xor = (given_answer_array + correct_answer_array) - ( given_answer_array & correct_answer_array)

    wrong_answers = xor.length
    score_per_choice = 1/total_number_of_choices.to_f

    #puts "   Scoring helper: [#{total_number_of_choices} options] given:[#{given_answer_array}] correct: #{correct_answer_array} wrong answers:#{wrong_answers} --> score[#{(1 - wrong_answers * score_per_choice).round(2)}] "
    score = (1 - wrong_answers * score_per_choice).round(2)

    return score
  end

  ###########
  def truefalse(given_answer_hash, correct_answer_hash, total_number_of_choices)
    # We have a blank answer, 0 score default for blank, no freebee score for implicitly blank options
    if given_answer_hash.empty?
      return 0.0
    end

    number_correct_answer = 0
    correct_answer_hash.each do |name, value|
      if given_answer_hash[name] == value
        number_correct_answer += 1
      end
    end
    score = (number_correct_answer.to_f/total_number_of_choices).round(2)

    return score

  end
end
