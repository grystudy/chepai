	require 'sidetiq/web'
	require 'sidekiq/web'
Rails.application.routes.draw do
  get 'ctrl/begin_all'
  namespace :api do 
  	namespace :v1 do
  		resources :weizhang ,only: :none do 
  			collection do
  				post :subscribe
          get :subscribe
        end
  		end
  	end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	mount Sidekiq::Web ,at: "/a"
	# mount Sidetiq::Web ,at: "/b"
end
