require 'query_helper.rb'

class QueryWorker
	include Sidekiq::Worker

	def Write(fileName, data)
		return if !data
		dirName=File.dirname(fileName)  	  
		if(!File.directory?(dirName))
			Dir.mkdir(File.dirname(fileName))
		end
		File.open(fileName, "w", :encoding => 'UTF-8') do |io|
			data.each_with_index do |line,i|
				io.write line.join("\t")
				if i != data.count - 1            
					io.write("\r\n")
				end
			end
		end
	end 

	def perform(name, count)
		zhunde  = WeizhangItem.all
		p zhunde.class

		# dop = []
		# zhunde.each do |variable|
		# 	li = []
		# 	li << variable.info
		# 	num = variable.weizhang_queries.take.plate_number
		# 	cp = num.che_pais.where(ftf: 1)
		# 	uucp = num.uu_che_pais.where(ftf: 1)
		# 	if cp.size > 0
		# 		li << cp.first.to_json
		# 	elsif uucp.size > 0 
		# 		li << uucp.first.to_json
		# 	else
		# 		next
		# 	end

		# 	dop << {info: li[0], car: li[1]} 
		# 	if dop.size == 100
		# 		Write('100条够不.json',[[dop.to_json]])
		# 		break
		# 	end
		# end

		GetuiHelper.notificate '开始全遍历',''
		city_info = WeizhangInfo.new.get_city_info
		unless city_info
			puts 'no cityinfo response'
			return
		end
		city_info = city_info[:configs]
		items = UUChePai.where(ftf: [nil,2]).all
		p items.size
		QueryHelper.loop items,city_info
		items = ChePai.where(ftf: [nil,2]).all
		p items.size
		QueryHelper.loop(items,city_info) { |uuitem| city_info.weizhang_provience_get_short_name uuitem.provience_name }
	end
end