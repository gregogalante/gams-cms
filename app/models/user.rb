class User < ActiveRecord::Base

  before_save {
    self.email = self.email.downcase
  }

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 50}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: 6, maximum: 50}
  validates :permissions, presence: true, numericality: { :greater_than_or_equal_to => 0 }

  has_secure_password
end
