class QuizzesQuestion < ActiveRecord::Base

  acts_as_list

  #Snapshot of results for a user
  attr_accessible :quiz_id, :question_id, :position

end