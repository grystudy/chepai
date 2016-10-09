class GetuiHelper
	@app_id = 'JxYKP0yduy6jU3qvM4pWI3'
	@app_key = 'D4CJtwxXOY62bILPy88o54'
	@master_secret = '0rVbaeBnUC9OIzoptES0y1'
	@cid_1 = '359ecfc2eedfef72081c29076faacc3b'
	@pusher = IGeTui.pusher(@app_id, @app_key, @master_secret)
	@client_1 = IGeTui::Client.new(@cid_1)
	@s_lock = Mutex.new

	class << self
		def notificate title,text
			@s_lock.synchronize do
				single_message = IGeTui::SingleMessage.new
				template = IGeTui::NotificationTemplate.new
				template.logo = 'push.png'
				template.logo_url = 'http://www.igetui.com/wp-content/uploads/2013/08/logo_getui1.png'
				template.title = title
				template.text = text
				template.set_push_info("open", 4, "message", "")
				template.transmission_type = 1
    		# template.transmission_content = "请填入透传内容"

				single_message.data = template
				single_message.is_offline = true
				single_message.offline_expire_time= 24 * 3600 * 1000
				ret = @pusher.push_message_to_single(single_message, @client_1)
				ret["result"] == "ok"
			end
		end
	end
end