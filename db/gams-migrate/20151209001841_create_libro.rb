class CreateLibro < ActiveRecord::Migration 
   def change 
   create_table :libro do |t| 
    t.timestamps null: false 
    t.text 'url' 
    t.text 'title_it' 
    t.text 'descrizione_it' 
    t.text 'immagine_it' 
    t.text 'title_en' 
    t.text 'descrizione_en' 
    t.text 'immagine_en' 
    t.text 'title_de' 
    t.text 'descrizione_de' 
    t.text 'immagine_de' 
    t.text 'title_fr' 
    t.text 'descrizione_fr' 
    t.text 'immagine_fr' 
   end 
 end
end