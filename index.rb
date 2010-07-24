#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'twitter/twitter.rb'

get '/' do
 erb :index 
end

post '/login' do
  
  twitter = TwitterOauth.new(params[:id], params[:pass])
  twitter.registry()
  
end
