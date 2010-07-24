#!/usr/bin/env ruby

require 'twitter/auth.rb'
require 'rubygems'
require 'oauth'
require 'yaml'
require 'cgi'
require 'cgi/session'
require 'json'

class TwitterOauth

  ACCOUNT_YAML = "twitter/.account.yaml"

  def initialize(id, pass)
    @account = {:id => id, :password => pass} 
    @yaml = YAML.load_file(ACCOUNT_YAML)
  end

  def registry
    cgi = CGI.new
    session = CGI::Session.new(
      cgi,{"new_session" => true, "tmpdir" => "./work/"}
    )

    consumer = OAuth::Consumer.new(
      @yaml["consumer_key"], @yaml["consumer_secret"],
      {:site => "http://twitter.com"}
    )

    optprm = { :oauth_callback => "http://naotos.ddo.jp/init" }
    rquest_token = consumer.get_request_token(optprm, {})
    session["request_token"] = request_token.token
    session["request_token_secret"] = request_token.secret
    print cgi.header( 'Location' => request_token.authorize_url)
  end

  def post(word)
    response = @access_token.post(
      'http://twitter.com/statuses/update.json',
      'status' => "#{word}"
    )
  rescue => e
    p e
  end

  def followers(page = 0)
    response = @access_token.get(
      'http://twitter.com/statuses/followers.json'
    )

   JSON.parse(response.body)
  rescue => e
    p e
  end
  
end
