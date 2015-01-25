#!/usr/bin/env ruby

require 'rest_client'
require 'mechanize'
require 'json'
require 'highline/import'

REDIRECT_URI = "http://localhost"
CLIENT_ID = "l92770tjhgxp9ji1k0ejwovtessqgno"
TWITCH_API_BASE = "https://api.twitch.tv/kraken"
TWITCH_IMPLICIT_GRANT_URL = "https://api.twitch.tv/kraken/oauth2/authorize?response_type=token&client_id=#{CLIENT_ID}&redirect_uri=#{REDIRECT_URI}&scope=user_subscriptions+user_read"

def run_setup
  mech = Mechanize.new
  puts "This script requires access to user_read and user_subscriptions as per https://github.com/justintv/Twitch-API/blob/master/authentication.md#scopes"
  puts "If you are not OK with this, turn back now"
  puts ""
  puts "Please log in to Twitch.  These credentials will not be stored"
  username = ask("Username: ") 
  password = ask("Password: ") { |text| text.echo = false }
  oauth_page = mech.get(TWITCH_IMPLICIT_GRANT_URL)
  # The OAuth redirect will fail because we aren't actually accepting
  # requests on localhost, but that's ok... we just need that redirect URL
  # since it has the access_token in it
  begin
    oauth_page.form_with(:action => "/kraken/oauth2/login") do |form|
      form.field_with(:name => "user[login]").value = username
      form.field_with(:name => "user[password]").value = password
    end.click_button
  rescue
  end
  mech.current_page.links[0].uri.to_s =~ /access_token=(.*)&/
  access_token = $1  
  # Open the config file and write out the token
  rc_file = File.open(File.join(ENV['HOME'], '.spazrc'), 'w')
  rc_file.write({:access_token => access_token}.to_json)
  rc_file.close
end


begin
  rc_file = File.open(File.join(ENV['HOME'], '.spazrc'))
  rc_file_json = JSON.parse(rc_file.read)
  access_token = rc_file_json['access_token']
  raise KeyError if access_token.nil?
rescue
  run_setup
end

#puts "DEBUG: config found. access_token: #{access_token}"

streams = JSON.parse(RestClient.get(TWITCH_API_BASE + "/streams/followed?oauth_token=#{access_token}").body)["streams"]


counter = 1
streams.each do |stream|
  puts "#{counter}. #{stream["channel"]["status"]} by #{stream["channel"]["display_name"]} - #{stream["game"]} with #{stream["viewers"]} viewers"
  counter += 1
end

