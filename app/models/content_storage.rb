class ContentStorage < ActiveRecord::Base
  # Fields
  attr_accessible :content_data, :content_hash

  # Validations
  validates :content_hash, presence: true, uniqueness: true

  def self.by_hash(hash)
    ContentStorage.where(content_hash: hash).first
  end

  def self.by_content(content)
    by_hash(generate_hash(content))
  end

  def self.generate_hash(content)
    Digest::MD5.hexdigest(content)
  end

  # Add content to storage
  #
  # Returns hash
  def self.add_content(content)
    hash = generate_hash(content)
    unless ContentStorage.exists?(content_hash: hash)
      ContentStorage.create! content_hash: hash, content_data: content
    end

    hash
  end

end
