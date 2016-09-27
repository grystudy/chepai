class WeizhangQuery < ApplicationRecord
  belongs_to :plate_number
  has_and_belongs_to_many :weizhang_items
end
