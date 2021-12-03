Rails.application.routes.draw do
  get '/callback', to: 'login#callback'
  get '/login', to: 'login#login'
  get '/randomize', to: 'randomizer#randomize'
end