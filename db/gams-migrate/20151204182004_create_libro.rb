class CreateLibro < ActiveRecord::Migration 
   def change 
   create_table :libro do |t| 
    t.timestamps null: false 
    t.text 'url' 
    t.text 'title_it' 
   end 
 end
end