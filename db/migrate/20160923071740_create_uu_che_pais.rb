class CreateUuChePais < ActiveRecord::Migration[5.0]
  def change
    create_table :uu_che_pais do |t|
      t.string :chepai
      t.string :fadongji
      t.string :chejia
    end
    add_index :uu_che_pais, :chepai
  end
end
