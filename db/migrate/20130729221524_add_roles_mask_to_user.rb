class AddRolesMaskToUser < ActiveRecord::Migration
  def up
    add_column :users, :roles_mask, :integer
    add_index :users, :roles_mask

    User.find_each do |user|
      role = if user.is_admin?
               :admin
             elsif user.is_manager?
               :user_manager
             elsif user.is_student?
               :student
             end

      if role
        user.roles << role
        user.save
      end
    end

    remove_column :users, :is_admin
    remove_column :users, :is_manager
  end

  def down
    add_column :users, :is_admin, :boolean
    add_column :users, :is_manager, :boolean

    User.find_each do |user|
      if user.is? :admin
        user.is_admin = true
      elsif user.is? :user_manager
        user.is_manager = true
      end

      user.save
    end

    remove_column :users, :roles_mask
  end
end
