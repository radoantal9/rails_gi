require 'uri'

# TODO: Make customization replacement inline, for some reason it is currently wrapping prior text in <p>
module ApplicationHelper
  # Render with org HTML resources
  def render_text_block(text_block, course = @course)
    html = text_block.raw_content
    org = current_user.try :org

    # Valid [[KEY]] or [[OPTIONAL:KEY]]
    html.gsub! /\[\[([\w ]+:?[\w]+)\]\]/i do |match|
      org_key = $1
      org_res = org && (org.org_resources.by_key(org_key, course).first || org.org_resources.by_key(org_key).first)

      org_key_type = org_key.split(":")[0]

      # If value for key is available then show it, regardless of optional or not
      if org_res
        org_res.org_value
      else
        # Show blank if optional Key is missing and user is a student, otherwise show placeholder message
        if org_key_type == "OPTIONAL" and current_user.is_student?
          "<span class=\"optional-content-missing-key-#{org_key.split(":")[1]}\"></span>"
        else
          "<span style=\"background-color:yellow\">Organization Specific content placeholder (<b>[[#{org_key}]]</b>)</span>"
        end
      end

    end

    content_tag :div, html.html_safe, class: 'text_block_wrap'
  end

  def render_statement(question)
    content_tag :div, question.statement.try(:html_safe), class: 'question_statement'
  end

  # Enable redactor
  def input_text_block(form)
    form.text_area :raw_content, class: 'text_block_raw_content text_block_redactor'
  end
  
  def as_date(dt)
    dt.to_date if dt
  end
  
  def highlight_excerpt(text, query)
    if text && text.present?
      ex = excerpt(strip_tags(text.to_s), query, radius: 50, separator: ' ')
      if ex
        highlight(ex, query) 
      else
        ''
      end
    end 
  end

  def search_t(array_arg, query)
    if array_arg
      array_arg.each do |elem|
        if elem && strip_tags(elem).to_s.downcase.include?(query.downcase)
          return true
        end
      end
      false
    else
      false
    end
  end

  def option_responses_count(question_id, *args)
    if @given_answers
      content_tag :div, class: 'badge' do
        answer = args.map {|k| QuestionHelper.uniq_name_creator(k) }
        count = @given_answers[@question.id] && @given_answers[@question.id][answer]
        count ||= 0

        count.to_s
      end
    end
  end
end
