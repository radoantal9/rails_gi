class CreateAnonymousStudents < ActiveRecord::Migration
  def change
    create_table :anonymous_students do |t|
      t.integer :org_id

      t.timestamps
    end
    add_index :anonymous_students, :org_id

    add_column :question_response_bases, :anonymous_student_id, :integer
    add_index :question_response_bases, :anonymous_student_id
  end
end
