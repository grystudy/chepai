class CreateWeizhangQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :weizhang_queries do |t|
      t.references :plate_number, foreign_key: true, index:true
      t.datetime :time
    end
  end
end
