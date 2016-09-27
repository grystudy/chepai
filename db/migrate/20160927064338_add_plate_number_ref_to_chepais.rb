class AddPlateNumberRefToChepais < ActiveRecord::Migration[5.0]
  def change
    add_reference :che_pais, :plate_number, foreign_key: true, index:true
    add_reference :uu_che_pais, :plate_number, foreign_key:true, index:true
  end
end
