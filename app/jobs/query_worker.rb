require 'query_helper.rb'

class QueryWorker
	include Sidekiq::Worker
	def perform(name, count)
		GetuiHelper.notificate '开始全遍历',''
		city_info = WeizhangInfo.new.get_city_info
		unless city_info
			puts 'no cityinfo response'
			return
		end
		city_info = city_info[:configs]
		QueryHelper.loop UUChePai.all,city_info
		QueryHelper.loop(ChePai.all,city_info) { |uuitem| city_info.weizhang_provience_get_short_name uuitem.provience_name }
	end
end