class RenameNameAsCompany < ActiveRecord::Migration
  def change
		#rename_column :tenants, :name, :company
  end

  def down
  end
end
