class Field < ActiveRecord::Base

  before_save {
    self.name = self.name.downcase
    self.name = self.name.parameterize('_')
  }

  belongs_to :pages

  FIELD_LIST = %w(text textarea number editor image repeater)

  validates_uniqueness_of :name, :scope => :page_id
  validates_inclusion_of :type_field, :presence => true, :in => FIELD_LIST

  # Traco
  translates :value

end
