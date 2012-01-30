
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'supermodel'
require 'json'

#
# For documentation, see:
#   https://github.com/maccman/supermodel/blob/master/lib/supermodel/base.rb
#
class Inventor < SuperModel::Base
	include SuperModel::RandomID
	attributes :name
end

class Idea < SuperModel::Base
  include SuperModel::RandomID
  belongs_to :inventor
end

class RestfulServer < Sinatra::Base
	INVENTOR = Inventor.create!( :name => "ANONYMOUS" )
	
  # helper method that returns json
  def json_out(data)
    content_type 'application/json', :charset => 'utf-8'
    data.to_json + "\n"
  end

  # displays a not found error
  def not_found
    status 404
    body "not found\n"
  end

  # obtain a list of all ideas
  def list_ideas
    json_out(Idea.all)
  end
  
  # obtain a list of all inventors
  def list_inventors
  	json_out(Inventor.all)
	end

  # display the list of ideas
  get '/' do
    list_ideas
  end

  # display the list of ideas
  get '/ideas' do
    list_ideas
  end
  
  # displays the list of inventors
  get '/inventors' do 
  	list_inventors
	end

  # create a new idea
  post '/ideas' do
    idea = Idea.create!(JSON.parse(request.body.read))
    if idea.has_attribute?("inventor")
    	idea.inventor.save
  	else
    	idea.inventor = INVENTOR
  	end
  	idea.save
    json_out(idea)
  end

  # get an idea by id
  get '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    json_out(Idea.find(params[:id]))
  end
  
  #get an inventor by id
  get '/inventors/:id' do
  	unless Inventor.exists?(params[:id])
  		not_found
  		return
		end
		
		json_out(Inventor.find(params[:id]))
	end

  # update an idea
  put '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    idea = Idea.find(params[:id])
    idea.update_attributes!(JSON.parse(request.body.read))
    json_out(idea)
  end

  # delete an idea
  delete '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    Idea.find(params[:id]).destroy
    status 204
    "idea #{params[:id]} deleted\n"
  end
  
  # delete an inventor
  delete '/inventors/:id' do
  	unless Inventor.exists?(params[:id])
  		not_found
  		return	
		end
		
		Inventor.find(params[:id]).destroy
		status 204
		"inventor #{params[:id]} deleted\n"
	end

  run! if app_file == $0
  
end