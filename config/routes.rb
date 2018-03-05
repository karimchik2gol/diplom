Rails.application.routes.draw do
  get 'main/index'
  post 'create', to: 'main#create', as: 'create_main' 

  root to: 'main#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
