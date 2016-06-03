class RemoveTenantIdsFromTablesToRemoveMilia < ActiveRecord::Migration
  def up
   remove_column  :orgs                       , :tenant_id
   remove_column  :question_grade_reports     , :tenant_id
   remove_column  :questions                  , :tenant_id
   remove_column  :quiz_results               , :tenant_id
   remove_column  :quizzes                    , :tenant_id
   remove_column  :quizzes_questions          , :tenant_id
   remove_column  :text_blocks                 , :tenant_id
   remove_column  :users                      , :tenant_id
    
    #remove_index  :question_grade_reports  ,  :tenant_id
    #remove_index  :questions               ,  :tenant_id
    #remove_index  :quiz_results            ,  :tenant_id
    #remove_index  :quizzes                 ,  :tenant_id
    #remove_index  :quizzes_questions       ,  :tenant_id
    #remove_index  :users                   ,  :tenant_id
    
    #drop_table :eulas
    drop_table :tenants_users
    drop_table :tenants
  end

  def down
  end
end
