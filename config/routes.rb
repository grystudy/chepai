	require 'sidetiq/web'
	require 'sidekiq/web'
Rails.application.routes.draw do
  get 'ctrl/begin_all'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	mount Sidekiq::Web ,at: "/a"
	# mount Sidetiq::Web ,at: "/b"
end
