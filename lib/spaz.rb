require File.expand_path('spaz/spaz_configuration', File.dirname(__FILE__))

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
    choice = ask("Choose a stream: ", Integer) { |num| num.in = 1..streams.size}
    Launchy.open(streams[choice-1]["channel"]["url"]) unless choice==0
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
    streams = JSON.parse(RestClient.get(@@twitch_api_base + "/streams/followed?oauth_token=#{@access_token}").body)["streams"]
  end

end
