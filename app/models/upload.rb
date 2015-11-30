class Upload < ActiveRecord::Base

  # Paperclip
  has_attached_file :file, styles: { medium: "800x800>", thumb: "250x250>" }
  validates_attachment_content_type :file, content_type: /\Aimage\/.*\Z/
  # Traco
  translates :description

end
