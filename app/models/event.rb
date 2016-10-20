class Event < ApplicationRecord
  has_many :comments 
  def self.search(search)
    if search
      self.where("title LIKE :search OR description LIKE :search OR location LIKE :search", search: "%#{search}%")
    else
      self.all
    end
  end
end
