require 'date'
class PlateNumber < ApplicationRecord
  has_many :uu_che_pais, class_name: "UUChePai"
  has_many :che_pais
  has_many :weizhang_queries,-> { includes :weizhang_items }

  def need_requery?
    last_query = weizhang_queries.order(time: :desc).first
    return true unless last_query
    (DateTime.now - last_query.time.to_datetime).abs.to_f > 100
  end
end
