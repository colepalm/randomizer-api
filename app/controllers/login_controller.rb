require 'http'
require 'uri'

class LoginController < ApplicationController
  def initialize
    @oauth_client = OAuth2::Client.new(Rails.configuration.x.oauth.client_id,
                                       Rails.configuration.x.oauth.client_secret,
                                       authorize_url: '/authorize',
                                       site: Rails.configuration.x.oauth.idp_url,
                                       token_url: '/api/token',
                                       redirect_uri: Rails.configuration.x.oauth.redirect_uri)
  end

  # The OAuth callback
  def callback
    if params[:error]
      puts "Error logging in: ", params
      render json: {status: "error", code: 400, message: "Unable to login"}
    end

    Rails.cache.write("user_code", params[:code])

    code = Rails.cache.fetch("user_code")

    Rails.cache.fetch("user_token_#{code}", expires_in: 1.hours) do
      # Make a call to exchange the authorization_code for an access_token
      response = @oauth_client.auth_code.get_token(code)

      # Extract the access token from the response
      response.to_hash[:access_token]
    end

    token = Rails.cache.fetch("user_token_#{code}")

    HTTP.headers(:accept => "application/json")
        .auth("Bearer #{token}")
        .get('https://api.spotify.com/v1/me')

    redirect_to "#{ENV['REDIRECT_URL']}/randomize"
  end

  def logout
    # Invalidate session with Spotify
    @oauth_client.request(:get, '/logout')

    # Reset Rails session
    reset_session

    head :ok
  end

  def login
    redirect_to @oauth_client.auth_code.authorize_url
  end
end