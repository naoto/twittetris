require 'rubygems'
require 'oauth'
require 'yaml'
require 'cgi'
require 'cgi/session'
require 'json'

class TwitterOauth

  ACCOUNT_YAML = "twitter/.account.yaml"

  def initialize
    @yaml = YAML.load_file(ACCOUNT_YAML)
  end

  def access_token(vrfy, req_token, secret)
    consumer = OAuth::Consumer.new(
      @yaml["consumer_key"], @yaml["consumer_secret"],
      {:site => "http://twitter.com"}
    )

    request_token = OAuth::RequestToken.new(
      consumer,
      req_token,
      secret
    )
   
    prm = { :oauth_verifier => vrfy } 
    request_token.get_access_token(prm)
  end

  def registry(id)
    consumer = OAuth::Consumer.new(
      @yaml["consumer_key"], @yaml["consumer_secret"],
      {:site => "http://twitter.com"}
    )

    optprm = { :oauth_callback => "http://naotos.ddo.jp/init" }
    consumer.get_request_token(optprm, {})

  end

  def auth(access_token, token_secret)
    @consumer = OAuth::Consumer.new(
      @yaml["consumer_key"], @yaml["consumer_secret"],
      {:site => "http://twitter.com"}
    )

    @access_token = OAuth::AccessToken.new(
      @consumer,
      access_token,
      token_secret
    )
  end

  def post(word)
    response = @access_token.post(
      'http://twitter.com/statuses/update.json',
      'status' => "#{word}"
    )
  rescue => e
    p e
  end

  def followers(name)
   
    user = []
    cursor = "-1"

    #while true do
      response = @access_token.get(
        "http://twitter.com/statuses/followers/#{name}.json",
        {'cursor' => cursor, 'lite' => "true"}
      )
     JSON.parse(response.body)
    #end

  rescue => e
    p e
  end
  
end
