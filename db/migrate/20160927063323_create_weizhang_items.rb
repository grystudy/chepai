class CreateWeizhangItems < ActiveRecord::Migration[5.0]
  def change
    create_table :weizhang_items do |t|
      t.text :info
    end
  end
end
