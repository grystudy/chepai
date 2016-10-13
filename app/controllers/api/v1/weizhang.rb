class Api::V1::WeizhangController < ApplicationController
	skip_before_action :verify_authenticity_token, :only => ["subscribe"]

	def subscribe
		puts request.content_type
		puts request.body.read

		render json: {rspcode: 250}
	end
end