require 'http'
require 'json'
require 'uri'


class RandomizerController < ApplicationController
  def initialize
    super
  end

  def randomize
    code = Rails.cache.fetch("user_code")
    token = Rails.cache.fetch("user_token_#{code}")

    offset = 0
    continue = true
    playlists = Array.new

    # Iterate over fetch playlist function until there are none left
    while continue
      values = fetch_playlists(token, offset)
      values[0].each { |item|
        playlists << item
      }
      total = values[1]

      offset += 50
      # Check that we have not gone beyond the number of playlists
      if total - offset < 0
        continue = false
      end
    end

    # Grab random playlist to return
    random = {}
    random['name'] = playlists.sample["name"]
    # TODO handle error here
    p json:random
    render json:random
  end

  def fetch_playlists(token, offset)
    response = HTTP.headers(:accept => "application/json")
                   .auth("Bearer #{token}")
                   .get("https://api.spotify.com/v1/me/playlists?limit=50&offset=#{offset}")

    body = JSON.parse(response.body)

    [body["items"], body["total"]]
  end
end