class ContentPageElement < ActiveRecord::Base

  # Relations
  belongs_to :content_page, touch: true
  belongs_to :element, polymorphic: true

  acts_as_list scope: :content_page

  # Fields
  attr_accessible :element
end
