class CreateAlbero < ActiveRecord::Migration 
   def change 
   create_table :albero do |t| 
    t.timestamps null: false 
    t.text 'url' 
    t.text 'title_it' 
   end 
 end
end