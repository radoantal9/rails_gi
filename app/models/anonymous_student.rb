class AnonymousStudent < ActiveRecord::Base
  # Relations
  belongs_to :org
  has_many :question_responses, dependent: :destroy

  # Scopes
  scope :by_org, ->(org) { where(org_id: org) }

  # Fields
  attr_accessible :org
end
