#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'twitter/twitter.rb'
require 'sequel'
require 'logger'

DB = Sequel.sqlite('strage.db', :loggers => [Logger.new($stdout)])
enable :sessions

configure do
#  DB.create_table :users do
#    primary_key :id
#    String :name
#    String :oauth_token
#    String :oauth_verifie
#    String :request_token
#    String :request_token_secret
#    String :access_token
#    String :access_token_secret
#  end
#    DB.create_table :followers do
#      primary_key :id
#      String :name
#      String :screen
#      String :image
#    end
#  DB.create_table :matchers do
#    primary_key :id
#    String :user_id
#    String :followers_id
#  end
end

get '/' do
 erb :index 
end

post '/login' do
  
  id = params[:id]
  redirect "/#{id}" unless DB[:users].where(:name => id).empty?

  twitter = TwitterOauth.new
  req_token = twitter.registry(id)

  session["userid"] = id
  session["request_token"] = req_token.token
  session["request_token_secret"] = req_token.secret
  redirect req_token.authorize_url
  
end

get '/init' do
  oauth_token = params["oauth_token"]
  oauth_vrfy = params["oauth_verifier"]
  req_token = session["request_token"]
  req_token_secret = session["request_token_secret"]  
  
  twitter = TwitterOauth.new
  access = twitter.access_token(oauth_vrfy, req_token, req_token_secret)

  users = DB[:users].insert(
                       :name => session["userid"],
		       :oauth_token => oauth_token,
		       :oauth_verifie => oauth_vrfy,
		       :request_token => req_token,
		       :request_token_secret => req_token_secret,
		       :access_token => access.token,
		       :access_token_secret => access.secret
  )
  user = DB[:users].first(:name => session["userid"])

  twitter.auth(access.token, access.secret)

  users = twitter.followers(session["userid"])
  users.each{ |twit|
    follower = DB[:followers].first( :name => twit["screen_name"])
    if follower.nil?
      follower = DB[:followers].insert(
	      :name => twit["screen_name"],
	      :screen => twit["name"],
	      :image => twit["profile_image_url"]
      )
      follower = DB[:followers].first( :name => twit["screen_name"])
    end
    DB[:matchers].insert(
	    :user_id => user[:id],
	    :followers_id => follower[:id]
    )
  }
  redirect "/#{session["userid"]}"
end

get '/:name' do
  @user = DB[:users].join(:matchers, :user_id => :id).join(
          :followers, :id => :followers_id).filter("users.name = ?", params[:name])
  redirect "/" if @user.nil?
  
  erb :tetris
end
