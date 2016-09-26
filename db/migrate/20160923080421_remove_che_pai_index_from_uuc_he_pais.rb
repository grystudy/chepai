class RemoveChePaiIndexFromUucHePais < ActiveRecord::Migration[5.0]
  def change
    remove_index :uu_che_pais,:chepai
  end
end
