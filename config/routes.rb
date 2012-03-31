VysRails::Application.routes.draw do
  resources :nodes
  resources :sessions
  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"

  get "a/404"
  get "a/about"
  get "a/contact"
  get "a/index"
  get "a/layout"
  get "a/people"
  get "a/work"

  match '/contact', :to => 'a#contact'
  match '/about',   :to => 'a#about'
  match '/404',    :to => 'a#404'
  match '/layout',  :to => 'a#layout'
  match '/people',  :to => 'a#people'
  match '/work',  :to => 'a#work'

  root :to => 'a#index'
end
