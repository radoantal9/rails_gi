class AddTenantToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :tenant, :integer
  end
end
