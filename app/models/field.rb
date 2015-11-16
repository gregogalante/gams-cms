class Field < ActiveRecord::Base

  before_save {
    self.name = self.name.downcase
    self.name = self.name.parameterize('_')
  }

  belongs_to :pages

  FIELD_LIST = %w(text textarea number editor file image repeater)

  validates_uniqueness_of :name, :scope => :page_id
  validates_inclusion_of :type_field, :presence => true, :in => FIELD_LIST


  # Paperclip
  has_attached_file :image, styles: { medium: "800x800>", thumb: "250x250>" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  has_attached_file :file

  # Traco
  translates :value

end
