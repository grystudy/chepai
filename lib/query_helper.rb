require 'getui_helper.rb'

class QueryHelper
	$s_lock = Mutex.new

	class << self
		def loop chepai_, city_info
			bus = []
			max_count = 16
			chepai_.each do |uuitem|
				if block_given?
					p_short_name = yield(uuitem)
					next unless p_short_name
					chepai = p_short_name + uuitem.chepai
				else
					chepai = uuitem.chepai
				end
				next unless chepai.size > 3
				bus << {no: chepai , entity: uuitem}
				if bus.size == max_count
					QueryHelper.go(bus,city_info)
					bus.clear
				end
			end
			QueryHelper.go(bus,city_info) unless bus.size == 0
			bus.clear	
		end

		def go array_hash,city_info
			a_thread = []
			array_hash.each do |v|
				chepai = v[:no]
				uuitem = v[:entity]
				a_thread << Thread.new do
					pro = chepai[0]
					city = chepai[1]
					city_code = nil
					city_info.each do |pro_json|
						city_item = pro_json.weizhang_provience_match(pro,city)
						next unless city_item
						city_code = city_item.weizhang_city_code
						break
					end
					plate_num = nil
					$s_lock.synchronize do
						plate_num = uuitem.plate_number 
						unless plate_num
							plate_num = get_plate_number_item(chepai)
							uuitem.plate_number = plate_num
							uuitem.save!
						end
						unless city_code
							set_ftf uuitem,0
							Thread.exit
						end
						unless plate_num.need_requery?
							p "#{plate_num.name}  not need to requery"
							Thread.exit
						end
					end
					begin
						response = WeizhangInfo.new(city_code,chepai,uuitem.fadongji,uuitem.chejia).get
					rescue Exception => ex_
						p "exception !!!!!!!!!!!!!!!!!!!!!!  #{ex_.message}"
						GetuiHelper.notificate '网络发生异常',''
						sleep(30)
						retry
						Thread.exit
					end
					rspcode = response.weizhang_response_code
					if rspcode
						p "#{chepai} #{rspcode} #{Thread.current}"
						$s_lock.synchronize do
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

							GetuiHelper.notificate 'save',"#{new_weizhang_item.size}个" if new_weizhang_item.size > 0
							new_weizhang_item.each do |i_|
								p "weizhang save !!!!!!!!!!!!!!!"
								new_query.weizhang_items.create(info: i_.to_json)
							end
							case rspcode
							when 20000, 21000
								ftf = 1
							when 50101
								ftf = 3
							else
								ftf = 2
							end
							set_ftf uuitem,ftf
						end
					end
				end
			end			
			a_thread.each do |thread|
				thread.join
			end
		end

		def get_plate_number_item full_chepai
			item = PlateNumber.where(name: full_chepai).take
			item = PlateNumber.create(name:full_chepai) unless item
			item
		end

		def set_ftf uuitem,ftf
			if !uuitem.ftf || uuitem.ftf != ftf
				p "ftf from #{uuitem.ftf} to #{ftf}"
				uuitem.ftf = ftf
				uuitem.save!
			end
		end
	end
end

class WeizhangInfo
	require 'digest/md5'
	include HTTParty
	base_uri 'http://www.loopon.cn'

	def initialize(city=nil, chepai=nil,fadongji=nil,chejia=nil)
		t = ","
		src = "{plate_num:#{chepai}#{t}body_num:#{chejia}#{t}engine_num:#{fadongji}#{t}city_id:#{city}#{t}car_type:02}"
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

	def get_city_info
		res = self.class.get("/traffic_violation/api/v1/cities")
		return nil unless res
		ok = res.code.to_i == 200
		return nil unless ok
		eval(res.to_s)
	end

	private
	def is_valid?
		@data_hash
	end
end

class Array
	def weizhang_provience_get_short_name name_
		each do |hash|
			name = hash.fetch :province_name,String.new
			name.force_encoding 'UTF-8'
			return hash.fetch :province_short_name,nil if name == name_
		end
		nil
	end
end

class Hash
	def	weizhang_provience_match(pro,city)
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