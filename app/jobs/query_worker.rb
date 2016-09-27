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
			city_info[:configs].each do |pro_json|
				city_item = pro_json.weizhang_pro_match(pro,city)
				next unless city_item
				city_code = city_item.weizhang_city_code
				break
			end			
			next unless city_code		
			plate_num = get_plate_number_item chepai
			next unless plate_num.need_requery?
			response = WeizhangInfo.new(city_code,chepai,uuitem.fadongji,uuitem.chejia).get
			rspcode = response.weizhang_response_code
			if rspcode
				p "#{chepai} #{rspcode}"
				new_query = plate_num.weizhang_queries.create(time: DateTime.now)
				his_array = response.weizhang_histories
				new_weizhang_item = his_array.select do |res_item_|
					!plate_num.weizhang_queries.to_a.index do |q_|
						q_.weizhang_items.to_a.index do |i_|
							i_.info == res_item_.to_json
							p 'found same  !!!!!!!!!!!!!!!!!!!!!!!!!!!!'
						end
					end
				end
				new_weizhang_item.each do |i_|
					p "weizhang save !!!!!!!!!!!!!!!"
					new_query.weizhang_items.create(info: i_.to_json)
				end
			end
		end
	end

	def get_plate_number_item full_chepai
		item = PlateNumber.where(name: full_chepai).take
		item = PlateNumber.create(name:full_chepai) unless item
		item
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
		t = "%26"
		src = "{plate_num=#{chepai}#{t}body_num=#{chejia}#{t}engine_num=#{fadongji}#{t}city_id=#{city}#{t}car_type=02}"
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

	def weizhang_response_code
		code = fetch :rspcode,nil
		code
	end

	def weizhang_histories
		fetch :historys,[]
	end
end