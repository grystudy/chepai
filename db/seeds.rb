# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'roo'

def ReadExcel(fileName, sheet_index)
  xlsx = Roo::Spreadsheet.open(fileName)
  lines=[]
  p xlsx.sheets
  sheet = xlsx.sheet(sheet_index)
  (sheet.first_row .. sheet.last_row).each do |row_no|
    row_a = []
    (sheet.first_column .. sheet.last_column).each do |col_no|
      cv = sheet.cell(row_no, col_no)
      row_a << cv
    end
    lines << row_a
  end
  xlsx.close
  lines
end

source_name = File.join(Rails.root, "weizhang.xlsx")
res = ReadExcel(source_name, 1)
hash_array = []
res.each_with_index do |line, index_|
  next if index_ == 0
  hash_array << {source_id: line[0],
                 chepai: line[1],
                 fadongji: line[2],
                 chejia: line[3],
                 x: line[4],
                 city_code: line[5],
                 city_name: line[6],
                 provience_code: line[7],
                 provience_name: line[8],
                 time: line[9],
                 time1: line[10]}
end

p hash_array.length
ChePai.create hash_array

source_name = File.join(Rails.root, "cars.xlsx")
res = ReadExcel(source_name, 0)
hash_array = []
add_uu_chepai = lambda do |i_|
  return unless i_
  hash_array << {chepai: i_[0],
                 fadongji: i_[2],
                 chejia: i_[1]}
end
str_to_uu = lambda do |str_|
  return nil unless str_
  str_ = str_.delete("\n").delete("\"").delete("\r")
  line = str_.split ","
  return nil unless line.length == 2 || line.size == 3
  return nil unless line[0].size > 0
  line
end

danhang_count = 0
res.each_with_index do |line, index_|
  next if index_ == 0
  line = line[0]
  next unless line
  next unless line.class == String
  if line.include? "\n"
    items = line.split("\r\n")
    items.each do |each_i_|
      add_uu_chepai.call(str_to_uu.call(each_i_))
    end
  else
    danhang_count = danhang_count + 1
    add_uu_chepai.call(str_to_uu.call(line))
  end
end
p danhang_count
p hash_array.length
UUChePai.delete_all
UUChePai.create hash_array

p "begin to create plate_number"
ChePai.each do |cp_|
  cp_.plate_number =QueryHelper.get_plate_number_item(cp_.chepai)
  cp_.save
end
UUChePai.each do |cp_|
  cp_.plate_number =QueryHelper.get_plate_number_item(cp_.chepai)
  cp_.save
end
p PlateNumber.all.size