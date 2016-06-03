class CourseQuizValidator < ActiveModel::Validator
  def validate(obj)
    if obj.is_a? ContentPagesLesson
      parent = obj.lesson
      child = obj.content_page
    elsif obj.is_a? LearningModulesLesson
      parent = obj.learning_module
      child = obj.lesson
    elsif obj.is_a? CoursesLearningModule
      parent = obj.course
      child = obj.learning_module
    end

    # Find intersections of parent and child
    parent_stat = parent.course_quiz_ids
    child_stat = child.own_quiz_ids

    shared_quiz_ids = parent_stat[:quiz_ids] & child_stat[:quiz_ids]
    unless shared_quiz_ids.empty?
      obj.errors[:base] << "Can't add \"#{child.name}\" to \"#{parent.name}\" - quiz ID #{shared_quiz_ids.to_a} duplication"
    end

    shared_question_ids = parent_stat[:question_ids] & child_stat[:question_ids]
    unless shared_question_ids.empty?
      obj.errors[:base] << "Can't add \"#{child.name}\" to \"#{parent.name}\" - question ID #{shared_question_ids.to_a} duplication"
    end

  end
end
