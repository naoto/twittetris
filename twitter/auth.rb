require 'rubygems'
require 'oauth'
require 'yaml'
require 'ostruct'

module Twitter
class Auth

  ACCOUNT_YAML = ".account.yaml"

  def initialize
    yaml = YAML.load_file(ACCOUNT_YAML)
    if yaml.class != "OpenStruct"
      @acount = OpenStruct.new(YAML.load_file(ACCOUNT_YAML))
    end
    
    oauth_init

    @consumer = OAuth::Consumer.new(
      @acount.consumer_key,
      @acount.consumer_secret,
      :site => 'http://twitter.com'
    )
    
    token_regist

    @access_token = OAuth::AccessToken.new(
      @consumer,
      @acount.access_token,
      @acount.access_token_secret
    )

  end

  def oauth_init
    
    @acount = OpenStruct.new if @acount.nil?
    if @acount.consumer_key.nil? || @acount.consumer_secret?
      puts "Register OAuh => http://twitter.com/apps"
      
      print "Input counsumer_key: "
      @acount.consumer_key = gets.chomp.strip
       
      print "Input consumer_secret: "
      @acount.consumer_secret = gets.chomp.strip
    end
 
  end

  def token_regist

    return unless @acount.access_token.nil?
    
    request_token = @consumer.get_request_token
    puts "Access this URL and approve => #{request_token.authorize_url}"

    print "Input OAuth Verifier: "
    oauth_verifier = gets.chomp.strip

    access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier
    )

    @acount.access_token = access_token.token
    @acount.access_token_secret = access_token.secret
    
    account_store
  end

  def account_store
    f = File.open(ACCOUNT_YAML,'w+')
    f.puts @acount.to_a.to_yaml
    f.close
  end
end
end
