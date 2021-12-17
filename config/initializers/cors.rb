Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://playlist-randomizer-f2a33.firebaseapp.com'
    resource '*', headers: :any, methods: [:get, :post]
  end
end