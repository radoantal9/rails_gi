namespace :search do
  desc "Rebuilding search documents"
  task :build => :environment do

    PgSearch::Multisearch.rebuild(User)
    PgSearch::Multisearch.rebuild(TextBlock)
    PgSearch::Multisearch.rebuild(Quiz)
    PgSearch::Multisearch.rebuild(ContentPage)
    PgSearch::Multisearch.rebuild(Lesson)
    PgSearch::Multisearch.rebuild(LearningModule)
    PgSearch::Multisearch.rebuild(Course)

    # Question has dynamic columns which prevent fast rebuild
    # so have to delete all and find_each to rebuild
    PgSearch::Document.delete_all(:searchable_type => "Question")
    Question.find_each { |record| record.update_pg_search_document }

    puts "User, Question, Invitation, TextBlock, Quiz, ContentPage, Lesson, LearningModule, Course update"
  end
end
