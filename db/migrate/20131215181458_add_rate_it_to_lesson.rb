class AddRateItToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :rate_lesson, :boolean
  end
end
