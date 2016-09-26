class QueryWorker
	include Sidekiq::Worker
	def perform(name, count)
		uri = $city_info_uri
		city_info = get_res_hash uri
		unless city_info
			puts 'no cityinfo response'
			return
		end

		puts UUChePai.all.length
	end

	private
	require 'net/http'

	$city_info_uri = "http://www.loopon.cn/traffic_violation/api/v1/cities"

	def get_res_hash uri
		res = Net::HTTP.get_response(URI(URI.encode(uri)))
		ok = res.code.to_i == 200
		return nil unless ok
		eval(res.body)
	end
end