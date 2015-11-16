class Type < ActiveRecord::Base

  before_save {
    self.url = self.url.parameterize('-')
    self.name = self.name.parameterize('_')
  }

  has_many :typefields

  validates :name, uniqueness: true, presence: true, length: {maximum: 50}
  validates :url, uniqueness: true, presence: true, length: {maximum: 50}

end
