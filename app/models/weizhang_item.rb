class WeizhangItem < ApplicationRecord
  has_and_belongs_to_many :weizhang_queries
end
