Rails.application.routes.draw do

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'homes#top'

  get '/expenses_list' => 'expenses#list'
  get '/expenses_album' => 'expenses#album'
  #get '/expenses_favorite' => 'expenses#favorite', as: :expense_favorites
  post 'favorite/:id' => 'favorites#create', as: 'create_favorite'
  delete 'favorite/:id' => 'favorites#destroy', as: 'destroy_favorite'

  resources :expenses do
    #resource :favorites, only: [:create, :destroy]
  end

  get 'user/unsubscribe' => 'users#unsubscribe'
  resources :users, only: [:show, :edit, :update]
  resources :genres, only: [:index, :create, :edit, :update]
  resources :aggregates, only: [:index, :create, :update]



end
