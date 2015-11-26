class CreateProdotto < ActiveRecord::Migration 
   def change 
   create_table :prodotto do |t| 
    t.timestamps null: false 
    t.text 'url' 
    t.text 'title_it' 
    t.text 'descrizione_it' 
   end 
 end
end