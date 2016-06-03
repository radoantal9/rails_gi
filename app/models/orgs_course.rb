class OrgsCourse < ActiveRecord::Base
  # Relations
  belongs_to :org
  belongs_to :course
  has_many :invitations, dependent: :destroy
  has_many :course_mails, as: :mail_object, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :surveys, dependent: :destroy

  # Scopes
  scope :by_course, ->(course) { where course_id: course }
  scope :by_org, ->(org) { where org_id: org }

  # Fields
  attr_accessible :enrollment_code, :org_id, :course_id, :course_mails_attributes
  accepts_nested_attributes_for :course_mails, allow_destroy: true
  normalize_attributes :enrollment_code

  # Validations
  validates :enrollment_code, uniqueness: true, presence: true
  validates :org, :course, presence: true
  validates :org_id, uniqueness: { scope: :course_id }
end
