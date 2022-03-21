Rails.application.routes.draw do
  devise_for :users
  get 'user/:id/edit' => 'users#edit', as: :edit_user

  get 'inquiries/new'
  post 'inquiries/create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'homes#top'

  get '/expenses_list' => 'expenses#list'
  get '/expenses_album' => 'expenses#album'

  post 'favorite/:id' => 'favorites#create', as: 'create_favorite'
  delete 'favorite/:id' => 'favorites#destroy', as: 'destroy_favorite'
  #get '/expenses_favorite' => 'favorites#index', on: :collection

  resources :expenses do
    #resource :favorites, only: [:create, :destroy]
    get '/expenses_favorite' => 'favorites#index', on: :collection
    get :search, on: :collection
  end


  patch 'user/:id' => 'users#update'
  delete 'user/withdraw' => 'users#withdraw'
  get 'user/unsubscribe' => 'users#unsubscribe'
  get 'user/my_page' => 'users#show'

  #resources :users, only: [:show, :edit, :update]
  #resources :genres, only: [:index, :create, :edit, :update]
  resources :aggregates, only: [:index, :create, :update]



end
