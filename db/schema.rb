# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141222092934) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "fuzzystrmatch"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"

  create_table "anonymous_students", force: true do |t|
    t.integer  "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "anonymous_students", ["org_id"], name: "index_anonymous_students_on_org_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "commentable_id",   null: false
    t.string   "commentable_type", null: false
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.text     "comment_subject"
    t.text     "comment_body"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["lft"], name: "index_comments_on_lft", using: :btree
  add_index "comments", ["rgt"], name: "index_comments_on_rgt", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "content_page_elements", force: true do |t|
    t.integer  "position"
    t.integer  "content_page_id"
    t.integer  "element_id"
    t.string   "element_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "content_page_elements", ["content_page_id"], name: "index_content_page_elements_on_content_page_id", using: :btree
  add_index "content_page_elements", ["element_id"], name: "index_content_page_elements_on_element_id", using: :btree
  add_index "content_page_elements", ["element_type"], name: "index_content_page_elements_on_element_type", using: :btree
  add_index "content_page_elements", ["position"], name: "index_content_page_elements_on_position", using: :btree

  create_table "content_pages", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
  end

  create_table "content_pages_lessons", force: true do |t|
    t.integer "position"
    t.integer "content_page_id"
    t.integer "lesson_id"
  end

  add_index "content_pages_lessons", ["content_page_id", "lesson_id"], name: "page_lesson_index", using: :btree
  add_index "content_pages_lessons", ["content_page_id"], name: "index_content_pages_lessons_on_content_page_id", using: :btree
  add_index "content_pages_lessons", ["lesson_id"], name: "index_content_pages_lessons_on_lesson_id", using: :btree

  create_table "content_storages", force: true do |t|
    t.string   "content_hash"
    t.text     "content_data"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "content_storages", ["content_hash"], name: "index_content_storages_on_content_hash", using: :btree

  create_table "course_mails", force: true do |t|
    t.integer  "email_type_cd"
    t.string   "email_subject"
    t.text     "email_message"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "mail_object_type"
    t.integer  "mail_object_id"
  end

  add_index "course_mails", ["email_type_cd"], name: "index_course_mails_on_email_type_cd", using: :btree
  add_index "course_mails", ["mail_object_type", "mail_object_id"], name: "index_course_mails_on_mail_object_type_and_mail_object_id", using: :btree

  create_table "course_pages", force: true do |t|
    t.integer  "course_id"
    t.integer  "page_id"
    t.string   "page_type"
    t.integer  "page_num"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "parent_page_num"
    t.integer  "learning_module_id"
    t.integer  "lesson_id"
    t.integer  "content_page_id"
    t.text     "quiz_ids_str"
    t.text     "question_ids_str"
    t.integer  "learning_module_page_num"
    t.integer  "lesson_page_num"
    t.integer  "content_page_num"
  end

  add_index "course_pages", ["content_page_id"], name: "index_course_pages_on_content_page_id", using: :btree
  add_index "course_pages", ["content_page_num"], name: "index_course_pages_on_content_page_num", using: :btree
  add_index "course_pages", ["course_id"], name: "index_course_pages_on_course_id", using: :btree
  add_index "course_pages", ["learning_module_id"], name: "index_course_pages_on_learning_module_id", using: :btree
  add_index "course_pages", ["learning_module_page_num"], name: "index_course_pages_on_learning_module_page_num", using: :btree
  add_index "course_pages", ["lesson_id"], name: "index_course_pages_on_lesson_id", using: :btree
  add_index "course_pages", ["lesson_page_num"], name: "index_course_pages_on_lesson_page_num", using: :btree
  add_index "course_pages", ["page_id"], name: "index_course_pages_on_page_id", using: :btree
  add_index "course_pages", ["page_num"], name: "index_course_pages_on_page_num", using: :btree
  add_index "course_pages", ["page_type"], name: "index_course_pages_on_page_type", using: :btree
  add_index "course_pages", ["parent_page_num"], name: "index_course_pages_on_parent_page_num", using: :btree

  create_table "course_variants", force: true do |t|
    t.integer  "course_id"
    t.text     "course_structure"
    t.text     "course_structure_cache"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "course_variants", ["course_id"], name: "index_course_variants_on_course_id", using: :btree

  create_table "courses", force: true do |t|
    t.string   "name"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.boolean  "course_pages_changed"
    t.string   "title"
  end

  add_index "courses", ["course_pages_changed"], name: "index_courses_on_course_pages_changed", using: :btree

  create_table "courses_learning_modules", id: false, force: true do |t|
    t.integer "course_id"
    t.integer "learning_module_id"
    t.integer "position"
  end

  add_index "courses_learning_modules", ["course_id", "learning_module_id"], name: "course_module_index", using: :btree
  add_index "courses_learning_modules", ["course_id"], name: "index_courses_learning_modules_on_course_id", using: :btree
  add_index "courses_learning_modules", ["learning_module_id"], name: "index_courses_learning_modules_on_learning_module_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "invitations", force: true do |t|
    t.integer  "orgs_course_id"
    t.integer  "user_id"
    t.string   "invitation_email"
    t.string   "invitation_state"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "invitation_token"
    t.datetime "sent_at"
    t.integer  "sent_count",       default: 0
  end

  add_index "invitations", ["invitation_email"], name: "index_invitations_on_invitation_email", using: :btree
  add_index "invitations", ["invitation_state"], name: "index_invitations_on_invitation_state", using: :btree
  add_index "invitations", ["invitation_token"], name: "index_invitations_on_invitation_token", using: :btree
  add_index "invitations", ["orgs_course_id"], name: "index_invitations_on_orgs_course_id", using: :btree
  add_index "invitations", ["sent_at"], name: "index_invitations_on_sent_at", using: :btree
  add_index "invitations", ["user_id"], name: "index_invitations_on_user_id", using: :btree

  create_table "learning_modules", force: true do |t|
    t.string   "name"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "title"
    t.text     "description"
    t.string   "description_image"
  end

  create_table "learning_modules_lessons", id: false, force: true do |t|
    t.integer "learning_module_id"
    t.integer "lesson_id"
    t.integer "position"
  end

  add_index "learning_modules_lessons", ["learning_module_id"], name: "learning_module_lesson_index", using: :btree
  add_index "learning_modules_lessons", ["lesson_id"], name: "index_learning_modules_lessons_on_lesson_id", using: :btree

  create_table "lessons", force: true do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "title"
    t.boolean  "rate_lesson"
  end

  create_table "morphed_photos", force: true do |t|
    t.string   "photo"
    t.integer  "user_detail_id"
    t.string   "tags"
    t.integer  "data_f"
    t.integer  "data_t"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "race_mask"
  end

  add_index "morphed_photos", ["race_mask"], name: "index_morphed_photos_on_race_mask", using: :btree
  add_index "morphed_photos", ["tags"], name: "index_morphed_photos_on_tags", using: :btree
  add_index "morphed_photos", ["user_detail_id"], name: "index_morphed_photos_on_user_detail_id", using: :btree

  create_table "org_resources", force: true do |t|
    t.integer  "org_id"
    t.integer  "course_id"
    t.string   "org_key",    null: false
    t.text     "org_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "org_resources", ["course_id"], name: "index_org_resources_on_course_id", using: :btree
  add_index "org_resources", ["org_id"], name: "index_org_resources_on_org_id", using: :btree
  add_index "org_resources", ["org_key"], name: "index_org_resources_on_org_key", using: :btree

  create_table "orgs", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "is_active"
    t.text     "contact"
    t.text     "notes"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "signup_key"
    t.text     "org_details"
    t.string   "domain"
  end

  add_index "orgs", ["domain"], name: "index_orgs_on_domain", using: :btree
  add_index "orgs", ["name"], name: "index_orgs_on_name", using: :btree
  add_index "orgs", ["signup_key"], name: "index_orgs_on_signup_key", using: :btree
  add_index "orgs", ["user_id"], name: "index_orgs_on_user_id", using: :btree

  create_table "orgs_courses", force: true do |t|
    t.integer  "org_id"
    t.integer  "course_id"
    t.string   "enrollment_code"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "orgs_courses", ["course_id"], name: "index_orgs_courses_on_course_id", using: :btree
  add_index "orgs_courses", ["org_id"], name: "index_orgs_courses_on_org_id", using: :btree

  create_table "pg_search_documents", force: true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "pgbench_accounts", primary_key: "aid", force: true do |t|
    t.integer "bid"
    t.integer "abalance"
    t.string  "filler",   limit: 84
  end

  create_table "pgbench_branches", primary_key: "bid", force: true do |t|
    t.integer "bbalance"
    t.string  "filler",   limit: 88
  end

  create_table "pgbench_history", id: false, force: true do |t|
    t.integer  "tid"
    t.integer  "bid"
    t.integer  "aid"
    t.integer  "delta"
    t.datetime "mtime"
    t.string   "filler", limit: 22
  end

  create_table "pgbench_tellers", primary_key: "tid", force: true do |t|
    t.integer "bid"
    t.integer "tbalance"
    t.string  "filler",   limit: 84
  end

  create_table "question_privacies", force: true do |t|
    t.integer  "course_id"
    t.integer  "org_id"
    t.integer  "question_id"
    t.integer  "question_privacy_cd", default: 0
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "question_privacies", ["course_id"], name: "index_question_privacies_on_course_id", using: :btree
  add_index "question_privacies", ["org_id"], name: "index_question_privacies_on_org_id", using: :btree
  add_index "question_privacies", ["question_id"], name: "index_question_privacies_on_question_id", using: :btree

  create_table "question_response_bases", force: true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.integer  "question_id"
    t.string   "content_hash"
    t.text     "given_answer"
    t.integer  "quiz_result_id"
    t.float    "score"
    t.text     "correct_answer"
    t.text     "details"
    t.integer  "question_privacy_cd",  default: 0
    t.string   "title"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "anonymous_student_id"
  end

  add_index "question_response_bases", ["anonymous_student_id"], name: "index_question_response_bases_on_anonymous_student_id", using: :btree
  add_index "question_response_bases", ["content_hash"], name: "index_question_response_bases_on_content_hash", using: :btree
  add_index "question_response_bases", ["question_id"], name: "index_question_response_bases_on_question_id", using: :btree
  add_index "question_response_bases", ["question_privacy_cd"], name: "index_question_response_bases_on_question_privacy_cd", using: :btree
  add_index "question_response_bases", ["quiz_result_id"], name: "index_question_response_bases_on_quiz_result_id", using: :btree
  add_index "question_response_bases", ["title"], name: "index_question_response_bases_on_title", using: :btree
  add_index "question_response_bases", ["type"], name: "index_question_response_bases_on_type", using: :btree
  add_index "question_response_bases", ["user_id"], name: "index_question_response_bases_on_user_id", using: :btree

  create_table "questions", force: true do |t|
    t.string   "title"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "retired"
    t.string   "question_type"
    t.string   "name"
    t.string   "content_hash"
    t.integer  "question_privacy_cd", default: 0
  end

  add_index "questions", ["content_hash"], name: "index_questions_on_content_hash", using: :btree
  add_index "questions", ["question_privacy_cd"], name: "index_questions_on_question_privacy_cd", using: :btree

  create_table "quiz_results", force: true do |t|
    t.integer  "user_id"
    t.integer  "quiz_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.float    "score",      default: 0.0
  end

  add_index "quiz_results", ["quiz_id"], name: "index_quiz_results_on_quiz_id", using: :btree
  add_index "quiz_results", ["user_id"], name: "index_quiz_results_on_user_id", using: :btree

  create_table "quizzes", force: true do |t|
    t.text     "name"
    t.text     "instructions"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "title"
  end

  create_table "quizzes_questions", id: false, force: true do |t|
    t.integer "quiz_id"
    t.integer "question_id"
    t.integer "position"
  end

  add_index "quizzes_questions", ["question_id"], name: "index_quizzes_questions_on_question_id", using: :btree
  add_index "quizzes_questions", ["quiz_id", "question_id"], name: "index_quizzes_questions_on_quiz_id_and_question_id", using: :btree
  add_index "quizzes_questions", ["quiz_id"], name: "index_quizzes_questions_on_quiz_id", using: :btree

  create_table "redactor_assets", force: true do |t|
    t.integer  "user_id"
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "redactor_assets", ["assetable_type", "assetable_id"], name: "idx_redactor_assetable", using: :btree
  add_index "redactor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_redactor_assetable_type", using: :btree
  add_index "redactor_assets", ["user_id"], name: "index_redactor_assets_on_user_id", using: :btree

  create_table "reminders", force: true do |t|
    t.integer  "orgs_course_id"
    t.integer  "user_id"
    t.string   "reminder_state"
    t.datetime "sent_at"
    t.integer  "sent_count",     default: 0
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "reminder_token"
  end

  add_index "reminders", ["orgs_course_id"], name: "index_reminders_on_orgs_course_id", using: :btree
  add_index "reminders", ["reminder_state"], name: "index_reminders_on_reminder_state", using: :btree
  add_index "reminders", ["reminder_token"], name: "index_reminders_on_reminder_token", using: :btree
  add_index "reminders", ["sent_at"], name: "index_reminders_on_sent_at", using: :btree
  add_index "reminders", ["user_id"], name: "index_reminders_on_user_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "surveys", force: true do |t|
    t.integer  "question_id"
    t.integer  "question_response_id"
    t.integer  "orgs_course_id"
    t.integer  "user_id"
    t.string   "survey_email"
    t.string   "survey_token"
    t.string   "survey_state"
    t.datetime "sent_at"
    t.integer  "sent_count",           default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "surveys", ["orgs_course_id"], name: "index_surveys_on_orgs_course_id", using: :btree
  add_index "surveys", ["question_id"], name: "index_surveys_on_question_id", using: :btree
  add_index "surveys", ["question_response_id"], name: "index_surveys_on_question_response_id", using: :btree
  add_index "surveys", ["survey_email"], name: "index_surveys_on_survey_email", using: :btree
  add_index "surveys", ["survey_state"], name: "index_surveys_on_survey_state", using: :btree
  add_index "surveys", ["survey_token"], name: "index_surveys_on_survey_token", using: :btree
  add_index "surveys", ["user_id"], name: "index_surveys_on_user_id", using: :btree

  create_table "text_blocks", force: true do |t|
    t.text     "private_title"
    t.text     "raw_content"
    t.text     "rendered_content"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "course_id"
    t.integer  "learning_module_id"
    t.integer  "lesson_id"
  end

  add_index "text_blocks", ["course_id"], name: "index_text_blocks_on_course_id", using: :btree
  add_index "text_blocks", ["learning_module_id"], name: "index_text_blocks_on_learning_module_id", using: :btree
  add_index "text_blocks", ["lesson_id"], name: "index_text_blocks_on_lesson_id", using: :btree

  create_table "user_details", force: true do |t|
    t.string   "user_photo"
    t.integer  "user_id"
    t.hstore   "user_data"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "main_photo_status_cd", default: 0
    t.string   "detected_user_photo"
    t.string   "registration_state"
    t.string   "cropped_user_photo"
    t.string   "mask_photo"
  end

  add_index "user_details", ["registration_state"], name: "index_user_details_on_registration_state", using: :btree
  add_index "user_details", ["user_data"], name: "index_user_details_on_user_data", using: :gist
  add_index "user_details", ["user_id"], name: "index_user_details_on_user_id", using: :btree

  create_table "user_events", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "learning_module_id"
    t.integer  "lesson_id"
    t.integer  "content_page_id"
    t.string   "event_type"
    t.datetime "event_time"
    t.hstore   "event_data"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "email"
    t.datetime "deleted_at"
  end

  add_index "user_events", ["content_page_id"], name: "index_user_events_on_content_page_id", using: :btree
  add_index "user_events", ["course_id"], name: "index_user_events_on_course_id", using: :btree
  add_index "user_events", ["deleted_at"], name: "index_user_events_on_deleted_at", using: :btree
  add_index "user_events", ["email"], name: "index_user_events_on_email", using: :btree
  add_index "user_events", ["event_time"], name: "index_user_events_on_event_time", using: :btree
  add_index "user_events", ["event_type"], name: "index_user_events_on_event_type", using: :btree
  add_index "user_events", ["learning_module_id"], name: "index_user_events_on_learning_module_id", using: :btree
  add_index "user_events", ["lesson_id"], name: "index_user_events_on_lesson_id", using: :btree
  add_index "user_events", ["user_id", "course_id", "event_type"], name: "index_user_events_on_user_id_and_course_id_and_event_type", using: :btree
  add_index "user_events", ["user_id", "course_id"], name: "index_user_events_on_user_id_and_course_id", using: :btree
  add_index "user_events", ["user_id"], name: "index_user_events_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "org_id"
    t.integer  "roles_mask"
    t.string   "provider"
    t.string   "uid"
    t.string   "authentication_token"
    t.string   "anonid"
  end

  add_index "users", ["anonid"], name: "index_users_on_anonid", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["org_id"], name: "index_users_on_org_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["roles_mask"], name: "index_users_on_roles_mask", using: :btree

  create_table "users_courses", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.string   "authentication_token"
  end

  add_index "users_courses", ["authentication_token"], name: "index_users_courses_on_authentication_token", using: :btree
  add_index "users_courses", ["course_id", "user_id"], name: "index_users_courses_on_course_id_and_user_id", using: :btree
  add_index "users_courses", ["course_id"], name: "index_users_courses_on_course_id", using: :btree
  add_index "users_courses", ["user_id"], name: "index_users_courses_on_user_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "word_definitions", force: true do |t|
    t.string   "word"
    t.text     "word_definition"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "word_definitions", ["word"], name: "index_word_definitions_on_word", using: :btree

  add_foreign_key "content_page_elements", "content_pages", name: "content_page_elements_content_page_id_fk"

  add_foreign_key "content_pages_lessons", "content_pages", name: "content_pages_lessons_content_page_id_fk"
  add_foreign_key "content_pages_lessons", "lessons", name: "content_pages_lessons_lesson_id_fk"

  add_foreign_key "courses_learning_modules", "courses", name: "courses_learning_modules_course_id_fk"
  add_foreign_key "courses_learning_modules", "learning_modules", name: "courses_learning_modules_learning_module_id_fk"

  add_foreign_key "learning_modules_lessons", "learning_modules", name: "learning_modules_lessons_learning_module_id_fk"
  add_foreign_key "learning_modules_lessons", "lessons", name: "learning_modules_lessons_lesson_id_fk"

  add_foreign_key "morphed_photos", "user_details", name: "morphed_photos_user_detail_id_fk"

  add_foreign_key "orgs_courses", "courses", name: "orgs_courses_course_id_fk"
  add_foreign_key "orgs_courses", "orgs", name: "orgs_courses_org_id_fk"

  add_foreign_key "quiz_results", "quizzes", name: "quiz_results_quiz_id_fk"
  add_foreign_key "quiz_results", "users", name: "quiz_results_user_id_fk"

  add_foreign_key "quizzes_questions", "questions", name: "quizzes_questions_question_id_fk"
  add_foreign_key "quizzes_questions", "quizzes", name: "quizzes_questions_quiz_id_fk"

  add_foreign_key "redactor_assets", "users", name: "redactor_assets_user_id_fk"

  add_foreign_key "text_blocks", "courses", name: "text_blocks_course_id_fk"
  add_foreign_key "text_blocks", "learning_modules", name: "text_blocks_learning_module_id_fk"
  add_foreign_key "text_blocks", "lessons", name: "text_blocks_lesson_id_fk"

  add_foreign_key "user_details", "users", name: "user_details_user_id_fk"

  add_foreign_key "users", "orgs", name: "users_org_id_fk"

  add_foreign_key "users_courses", "courses", name: "users_courses_course_id_fk"
  add_foreign_key "users_courses", "users", name: "users_courses_user_id_fk"

end
