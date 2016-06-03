
    class AddMissingIndexes < ActiveRecord::Migration
      def change
        add_index :users, :org_id
        add_index :courses_learning_modules, :course_id
        add_index :courses_learning_modules, :learning_module_id
        add_index :courses_learning_modules, [:course_id, :learning_module_id], :name => 'course_module_index'
        add_index :content_pages_lessons, :lesson_id
        add_index :content_pages_lessons, :content_page_id
        add_index :content_pages_lessons, [:content_page_id, :lesson_id], :name => 'page_lesson_index'
        add_index :redactor_assets, :user_id
        add_index :users_courses, :user_id
        add_index :users_courses, :course_id
        add_index :users_courses, [:course_id, :user_id]
        add_index :learning_modules_lessons, :learning_module_id, :name => 'learning_module_lesson_index'
        add_index :learning_modules_lessons, :lesson_id
      end
    end
