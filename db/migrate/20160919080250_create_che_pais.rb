class CreateChePais < ActiveRecord::Migration[5.0]
  def change
    create_table :che_pais do |t|
      t.integer :source_id
      t.string :chepai
      t.string :fadongji
      t.string :chejia
      t.string :x
      t.integer :city_code
      t.string :city_name
      t.integer :provience_code
      t.string :provience_name
      t.string :time
      t.string :time1

      t.timestamps
    end
  end
end
