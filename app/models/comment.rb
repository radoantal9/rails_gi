class Comment < ActiveRecord::Base
  # Relations
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: 'User', foreign_key: 'user_id', inverse_of: :authored_comments

  acts_as_nested_set scope: [:commentable_id, :commentable_type]

  # Scopes
  default_scope -> { order('created_at ASC') }
  scope :by_author, ->(user) { where(user_id: user) }
  scope :by_commentable, ->(commentable) { where(commentable_id: commentable.id, commentable_type: commentable.class.name) }

  # Fields
  attr_accessible :commentable, :author, :comment_body
  normalize_attribute :comment_subject, :comment_body, with: [:strip, :blank]

  # Validations
  validates :commentable, :author, :comment_body, presence: true

  # Helper method to check if a comment has children
  def has_children?
    self.children.any?
  end
end
