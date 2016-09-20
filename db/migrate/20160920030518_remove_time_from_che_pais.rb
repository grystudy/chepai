class RemoveTimeFromChePais < ActiveRecord::Migration[5.0]
  def change
    remove_column :che_pais, :time, :string
    remove_column :che_pais, :time1, :string
    remove_column :che_pais, :created_at, :datetime
    remove_column :che_pais, :updated_at, :datetime
    add_column :che_pais, :time, :datetime
    add_column :che_pais, :time1, :datetime
  end
end
