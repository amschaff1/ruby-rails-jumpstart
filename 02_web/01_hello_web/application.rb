
require 'bundler/setup'
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'json'
require 'roxml'
require 'yaml'


class ExampleServer < Sinatra::Base
  CONTENT_TYPES = {
    'txt'  => 'text/plain',
    'yaml'  => 'text/plain',
    'xml'  => 'text/xml',
    'json' => 'application/json'
  }

  #
  # helper method that takes a ruby object and returns a string
  # representation in the specified format
  #
  def reformat(data, format=params[:format])
    content_type CONTENT_TYPES[format], :charset => 'utf-8'
    case format
    when 'txt'
      data.to_s
    when 'yaml'
      YAML::dump(data)
    when 'xml'
      data.to_xml
    when 'json'
      data.to_json
    else
      raise 'Unknown format: ' + format
    end
  end

  #
  # a basic time service, a la:
  # http://localhost:4567/time.txt (or .xml or .json or .yaml)
  #
  get '/time.?:format?' do 
    reformat({ :time => Time.now })
  end

  #
  # outputs a message from the url as plain text,
  # a la : http://localhost:4567/echo/foo
  #
  get '/echo/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message]
  end

  #
  # outputs a message from the url parameter as plain text,
  # a la : http://localhost:4567/echo?message=foo
  #
  get '/echo' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message]
  end

  # outputs a message from the url in reverse as plain text,
  # a la: http://localhost:4567/reverse/foo
  #
  get '/reverse/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message].to_s.reverse
  end

  # outputs a message from the url parameter in reverse as plain text,
  # a la: http://localhost:4567/reverse?message=foo
  get '/reverse' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message].reverse
  end

	# outputs a message from the url in reverse as plain text,
	# a la: http://localhost:4567/piglatin/foo
  get '/piglatin/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    words = params[:message].split(" ")
    newWords = []
    words.each do |word|
    	newWords.push(word[1..-1] + word[0])
  	end
  	
  	newWords.join(" ")
  end

  # outputs a message from the url parameter in reverse as plain text,
	# a la: http://localhost:4567/piglatin?message=foo
  get '/piglatin' do
    content_type 'text/plain', :charset => 'utf-8'
    words = params[:message].split(" ")
    newWords = []
    words.each do |word|
    	newWords.push(word[1..-1] + word[0])
  	end
  	
  	newWords.join(" ")
  end

  # FIXME #3: implement snowball stemming service that translates the
  # message into a comma-separated list of tokens using the snowball
  # stemming algorithm
  get '/snowball/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message]
  end

  # FIXME #3: implement snowball stemming service that translates the
  # message into a comma-separated list of tokens using the snowball
  # stemming algorithm
  get '/snowball' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message]
  end

  run! if app_file == $0
end