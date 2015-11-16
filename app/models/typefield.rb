class Typefield < ActiveRecord::Base

  before_save {
    self.name = self.name.downcase
    self.name = self.name.parameterize('_')
  }

  TYPEFIELD_LIST = %w(text textarea number editor file image)

  validates_uniqueness_of :name, :scope => :type_id
  validates_inclusion_of :type_field, :presence => true, :in => TYPEFIELD_LIST

  # MANCA CONTROLLO CHE NAME SIA DIVERSO DA "TITLE"

  belongs_to :type

end
