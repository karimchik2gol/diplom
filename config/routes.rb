Rails.application.routes.draw do
  get 'main/index'
  get 'signal', to: 'main#signal'
  
  post 'parse_signal', to: 'main#parse_signal'
  post 'create', to: 'main#create', as: 'create_main' 

  root to: 'main#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
