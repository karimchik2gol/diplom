Rails.application.routes.draw do
  get 'main/index'
  get 'signal', to: 'main#signal'
  
  post 'parse_signal', to: 'main#parse_signal'
  post 'create', to: 'main#create', as: 'create_main'
  post 'statistic', to: 'main#statistic'
  post 'graphic', to: 'main#graphic'
  post 'spectre', to: 'main#spectre'
  post 'histograma', to: 'main#histograma'
  post 'correlation', to: 'main#correlation'
  post 'periodogramma', to: 'main#periodogramma'

  get 'generate_file', to: 'main#generate_file'

  root to: 'main#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
