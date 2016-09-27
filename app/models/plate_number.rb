class PlateNumber < ApplicationRecord
  has_many :uu_che_pais
  has_many :che_pais
  has_many :weizhang_queries
end
