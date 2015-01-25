module SpazConfiguration
  require 'highline/import'
  require 'mechanize'

  @scopes = ["user_subscriptions", "user_read"]

  def configure!(filepath=@conf_path)
    generate_token unless load_config and @access_token and not generate_new_token?
    write!
  end

  def load_config
    begin
      @conf_file = File.open(@conf_path)
      options = JSON.parse(@conf_file.read)
      @access_token = options['access_token']
    rescue
    end
  end

  private

  def write!
    @conf_file.close
    @conf_file = File.open(@conf_path, 'w')
    config = {"access_token" => @access_token}
    @conf_file.write(config)
  end

  # Routines that involve user prompting

  def generate_token
    auth = twitch_login_info
    oauth_page = mech.get(TWITCH_IMPLICIT_GRANT_URL)
    # The OAuth redirect will fail because we aren't actually accepting
    # requests on localhost, but that's ok... we just need that redirect URL
    # since it has the access_token in it
    begin
      oauth_page.form_with(:action => "/kraken/oauth2/login") do |form|
        form.field_with(:name => "user[login]").value = auth[:username]
        form.field_with(:name => "user[password]").value = auth[:password]
      end.click_button
    rescue
    end
    mech.current_page.links[0].uri.to_s =~ /access_token=(.*)&/
    @access_token = $1
  end
  
  def generate_new_token?
    puts "An existing access_token was found in #{@conf_path}"
    confirm = ask("Should a new access token be generated? [Y/N] ") { |yn| yn.limit = 1, yn.validate = /[yn]/i }   
    confirm.downcase == 'y'
  end

  def twitch_login_info
    puts "This script requires access to user_read and user_subscriptions as per https://github.com/justintv/Twitch-API/blob/master/authentication.md#scopes"
    puts "If you are not OK with this, turn back now"
    puts ""
    puts "Please log in to Twitch.  These credentials will not be stored"
    { :username => ask("Username: "), :password => ask("Password: ") { |text| text.echo = false } }
  end
end
