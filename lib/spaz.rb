require File.dirname(__FILE__) + '/spaz/spaz_configuration'

class Spaz
  require 'rest-client'
  require 'highline/import'
  require 'launchy'
  include SpazConfiguration

  @@twitch_api_base = "https://api.twitch.tv/kraken"

  def initialize(conf_path = File.join(ENV['HOME'], '.spazrc'))
    @conf_path = conf_path
    configure! unless load_config
  end

  def watch
    streams = list_followed_streams
    puts("")
    while true
      choice = ask("Which stream do you want to watch? [None]") { |num| num.default="0", num.validate = /^[0-9]+$/ }.to_i
      break unless choice > streams.size
      if choice == 0
        return
      end
    end
    Launchy.open(streams[choice-1]["channel"]["url"])
  end

  def list
    list_followed_streams
  end

  private

  def list_followed_streams
    streams = followed_streams
    counter = 1
    streams.each do |stream|
      puts "#{counter}. #{stream["channel"]["status"]} by #{stream["channel"]["display_name"]} - #{stream["game"]} with #{stream["viewers"]} viewers"
      counter += 1
    end
  end

  def followed_streams
    streams = JSON.parse(RestClient.get(TWITCH_API_BASE + "/streams/followed?oauth_token=#{@access_token}").body)["streams"]
  end

end
