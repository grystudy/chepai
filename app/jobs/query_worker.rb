class QueryWorker
	include Sidekiq::Worker
	def perform(name, count)
		uri = $city_info_uri
		city_info = get_res_hash uri
		unless city_info
			puts 'no cityinfo response'
			return
		end

		UUChePai.all.each do |uuitem|
			chepai = uuitem.chepai
			next unless chepai.size > 3
			pro = chepai[0]
			city = chepai[1]
			city_code = nil
			# car_head = ""
			city_info[:configs].each do |pro_json|
				city_item = pro_json.weizhang_pro_match(pro,city)
				next unless city_item
				city_code = city_item.weizhang_city_code
				# car_head = city_item.fetch :car_head,String.new
				break
			end
			
			next unless city_code		
			weizhang_info = WeizhangInfo.new(city_code,chepai,uuitem.fadongji,uuitem.chejia)
			response = weizhang_info.get
			p response
			if response.weizhang_response_ok?
				break
			end
		end
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

class WeizhangInfo
	require 'digest/md5'
	include HTTParty
	base_uri 'http://www.loopon.cn'

	def initialize(city, chepai,fadongji,chejia)
		@chepai = chepai
		s = "%26"
		t = s
		src = "{plate_num=#{chepai}#{t}body_num=#{chejia}#{t}engine_num=#{fadongji}#{t}city_id=#{city}#{t}car_type=02}"
    @car_info = src.gsub(t,s)
    @car_info = src
  end

	def get 
		@data_hash = nil
		car_info = @car_info
		return nil unless @car_info
		api_id = 2
		app_key = "c1a0dc80-3699-0134-fb7d-00163e081329"
		timestamp = Time.now.getutc.to_i
		sign = Digest::MD5.hexdigest(api_id.to_s + car_info + timestamp.to_s + app_key)
		res = self.class.get("/traffic_violation/api/v1/query",{query: {car_info: car_info, api_id: api_id, sign: sign, timestamp: timestamp}})
		return nil if !res		
		res = eval(res.to_s)
		return nil if !res
		@data_hash = res
	end

	private
	def is_valid?
		@data_hash
	end
end

class Hash
	def	weizhang_pro_match(pro,city)
		name = fetch :province_short_name,String.new
		name.force_encoding 'UTF-8'
		return nil unless name == pro
		cities = fetch :citys,nil
		return nil unless cities
		cities.each do |city_v|
			return city_v if city_v.weizhang_city_match city
		end
		nil
	end

	def weizhang_city_match city
		name = fetch :car_head ,nil
		return false unless name && name.size > 1
		name.force_encoding 'UTF-8'
		name[1] == city
	end

	def weizhang_city_code
		fetch :city_id,nil
	end

	def weizhang_response_ok?
		code = fetch :rspcode,nil
		code == "20000"
	end
end