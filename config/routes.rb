Rails.application.routes.draw do

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'homes#top'


  resources :expenses do
    resource :favorites, only: [:create, :destroy, :index]
  end

  get 'user/unsubscribe' => 'users#unsubscribe'
  resources :users, only: [:show, :edit, :update]
  resources :genres, only: [:index, :create, :edit, :update]
  resources :aggregates, only: [:index, :create, :update]



end
