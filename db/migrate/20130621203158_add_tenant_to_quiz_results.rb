class AddTenantToQuizResults < ActiveRecord::Migration
  def change
    add_column :quiz_results, :tenant, :integer
  end
end
