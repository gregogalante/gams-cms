class Page < ActiveRecord::Base

  before_save {
    self.url = self.url.parameterize('-')
  }

  has_many :fields

  validates :title, presence: true, length: {maximum: 50}
  validates :url, uniqueness: true, presence: true, length: {maximum: 50}

end
