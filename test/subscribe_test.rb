require 'minitest/autorun'
require 'net/http'
require 'json'
require 'openssl'
class SubscribeTest < MiniTest::Test
  # before run test, you need to change the variables in setup method.
  def setup

  end

  def test_status
  	ret = @pusher.get_client_id_status(@cid_1)
  	assert_equal ret["result"], "Online"
  end

  @@base_uri = "http://localhost:3000"

  def self.upload_record 
  	sub_url = "api/v1/weizhang/subscribe"
  	uri = @@base_uri +"/"+sub_url
  	uri = URI.parse uri
   	req = Net::HTTP::Get.new(uri.path)
  	req.body = {sb: 250}.to_json
  
  	p req.content_type='application/x-www-form-urlencoded'
  	 req['Content-Type'] = 'application/json'
  	  req['Content-Type'] ='text/plain'
  	http = Net::HTTP.new(uri.host,uri.port)
  	 # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		# begin
		res = http.request req

		p res.inspect
		unless res
			logger.warn uri + '>>>' + 'failed'
			return false
		end
		res_code = eval(res.body)[:rspcode]
	p res_code
		return res_code == 20000
		# rescue Exception => e
		# 	logger.warn uri + '>>>' + e.message
		# 	return false 
		# end
	end
end
SubscribeTest.upload_record