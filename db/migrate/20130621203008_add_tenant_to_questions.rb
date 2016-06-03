class AddTenantToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :tenant, :integer
  end
end
