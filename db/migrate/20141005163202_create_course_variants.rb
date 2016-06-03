class CreateCourseVariants < ActiveRecord::Migration
  def change
    create_table :course_variants do |t|
      t.integer :course_id
      t.text :course_structure
      t.text :course_structure_cache

      t.timestamps
    end

    add_index :course_variants, :course_id
  end
end
