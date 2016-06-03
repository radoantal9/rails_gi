class GuessQuestion
  def self.response(question, item, answer)
    correct = item["answer"]

    case item["type"]
    when "slider"
      delta = (correct.to_f - answer.to_f).abs / (item['max'].to_f - item['min'].to_f)
    when "number"
      delta = (correct.to_f - answer.to_f) / correct.to_i.abs.to_f
    when "text"
      delta = 100 # go to default
    else
      raise "Can't calculate the delta for a `#{question.question_type}` question"
    end

    delta = (delta * 100).to_i

    ranges = []
    question.xmlnode.xpath('//question/options/range').each do |range|
      diff = range['difference'].try(:gsub, /%$/, '')
      diff = diff.to_i if diff != nil
      ranges.push [diff, range['text']]
    end

    # Try to find default
    range = nil
    ranges.each_with_index do |item, index|
      if item[0] == nil
        range = index
        break
      end
    end

    ranges.each_with_index do |item, index|
      if range == nil # no default? Pick the first
        range = index
      else
        if item[0] != nil and item[0]/2 >= delta # qualify?
          if ranges[range][0] == nil or ranges[range][0] >= item[0] # is it better?
            range = index
          end
        end
      end
    end

    # correct, text, range_text
    opt = {
      correct: correct,
      text: item["type"] == "text"
    }

    unless opt[:text]
      opt[:range_text] = ranges[range][1]
    end

    return opt
  end
end
