class Image < ActiveRecord::Base
  
  # Paperclip
  has_attached_file :image, styles: { medium: "800x800>", thumb: "250x250>" }
  validates_attachment 	:image, :presence => true, :content_type => { :content_type => /\Aimage\/.*\Z/ }, :size => { :less_than => 5.megabyte }

  # Traco
  translates :title
  translates :description

end
