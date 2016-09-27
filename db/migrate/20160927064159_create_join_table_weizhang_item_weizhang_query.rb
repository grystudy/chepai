class CreateJoinTableWeizhangItemWeizhangQuery < ActiveRecord::Migration[5.0]
  def change
    create_join_table :weizhang_items, :weizhang_queries do |t|
      # t.index [:weizhang_item_id, :weizhang_query_id]
      # t.index [:weizhang_query_id, :weizhang_item_id]
    end
  end
end
