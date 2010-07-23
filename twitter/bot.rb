#!/usr/bin/env ruby

require 'auth.rb'
require 'rubygems'
require 'json'

class Bot < Twitter::Auth

  def initialize
    super
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
