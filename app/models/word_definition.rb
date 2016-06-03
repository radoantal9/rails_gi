class WordDefinition < ActiveRecord::Base
  # Fields
  attr_accessible :word, :word_definition
  normalize_attributes :word

  # Validations
  validates :word, :word_definition, presence: true
end
