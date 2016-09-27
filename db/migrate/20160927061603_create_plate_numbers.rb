class CreatePlateNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table :plate_numbers do |t|
      t.string :name
    end
    add_index :plate_numbers, :name
  end
end
