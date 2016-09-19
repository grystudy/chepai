class Aorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

	recurrence {secondly(1) }

	def perform
		 puts "sidetip ttt"
	end
end

module AA
	Aorker.perform_async
end