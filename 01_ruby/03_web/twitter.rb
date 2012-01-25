require 'open-uri'
require 'json'
require 'pp'

query = ARGV.shift														# get query string from command line

unless query																	# if there is no query
	puts "No query has been specified"
	exit																				# then exit
end

BASE_URL = "http://search.twitter.com/search.json?rpp=5&q="     # remote API url
#query     = "web services"                                         # query string
query_url = BASE_URL + URI.escape(query)                            # putting the 2 together


puts " ======================================== "                   # fancy output
puts "   #{query_url}"                                              # fancy output

object = open(query_url) do |v|                                     # call the remote API
  input = v.read                                                    # read the full response
  #puts input                                                       # un-comment this to see the returned JSON magic
  JSON.parse(input)                                                 # parse the JSON & return it from the block
end

puts " ======================================== "                   # fancy output
puts "   #{object['query']}"
puts "     #{object['refresh_url']}"
puts " ---------------------------------------- "

object['results'].each do |rt|                                # processing sub-elements
  puts
  puts "   * #{rt['text']}"
  puts "     #{rt['from_user']}"
end

puts                                                                # fancy output
puts " ---------------------------------------- "
puts " ======================================== "