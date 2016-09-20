# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'roo'
def ReadExcel(fileName,sheet_index)
  xlsx = Roo::Spreadsheet.open(fileName)
  lines=[]
  p xlsx.sheets
  sheet = xlsx.sheet(1)
  (sheet.first_row .. sheet.last_row).each do |row_no|
    row_a = []
    (sheet.first_column .. sheet.last_column).each do |col_no|
      cv = sheet.cell(row_no,col_no)
      row_a << cv
    end
    lines << row_a
  end
  xlsx.close
  lines
end

source_name = File.join(Rails.root,"weizhang.xlsx")
res = ReadExcel(source_name,1)
hash_array = []
res.each_with_index do |line,index_|
	next if index_ == 0 
	hash_array << {source_id:line[0] , 
		chepai:line[1],
		fadongji:line[2],
		chejia:line[3] || 0,
		x:line[4],
		city_code:line[5],
		city_name:line[6],
		provience_code:line[7],
		provience_name:line[8],
		time:line[9],
		time1:line[10]
		}
end

p hash_array.length
ChePai.create hash_array