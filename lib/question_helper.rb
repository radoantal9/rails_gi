module QuestionHelper
  extend self

  def partial_name(question)
    # return partial name for the question type
    raise "Question type is nil" if question.question_type.nil?

    case question.question_type
      when "single"
        return "/questions/single_choice_input"
      when "multiple"
        return "/questions/multiple_choice_input"
      when "truefalse"
        return "/questions/truefalse_input"
      when "match"
        return "/questions/matchpairs_input"
      when "guess"
        return "/questions/guess"
      when "essay"
        return "/questions/essay"
      when "gridform"
        return "/questions/gridform"
      when "survey"
        return "/questions/survey"
      else
        raise "No partial for question type (#{question.question_type})"
    end
  end

  def uniq_name_creator(name)
    uniq_name = name.downcase.gsub /[^a-z0-9]+/i, '_'
    uniq_name.gsub!(/(^_|_$)/, '')

    return uniq_name
  end
end
