class AddValidToChepais < ActiveRecord::Migration[5.0]
  def change
    add_column :che_pais, :ftf, :integer
    add_column :uu_che_pais, :ftf, :integer
  end
end
