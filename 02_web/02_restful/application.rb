
require 'bundler/setup'
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'supermodel'
require 'json'
require 'people_places_things'

include PeoplePlacesThings

#
# For documentation, see:
#   https://github.com/maccman/supermodel/blob/master/lib/supermodel/base.rb
#
class Inventor < SuperModel::Base
	include SuperModel::RandomID
	validates_uniqueness_of :name, :scope => :id
	validates_inclusion_of :gender, :in => %w( m f ), :unless => Proc.new { |inventor| inventor.name == "ANONYMOUS" }
end

class Idea < SuperModel::Base
  include SuperModel::RandomID
  belongs_to :inventor
  validates_presence_of :category
  validates_presence_of :text
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
	
	# nuke wihtout password -- deny
	post '/nuke' do
		status 400
		body "password required to delete inventors and ideas\n"
	end
	
	# destroy all ideas and inventors in the system
	post '/nuke/:password' do
		if params[:password] == "yesireallymeanit"
			Inventor.destroy_all
			Idea.destroy_all
			
			status 204
			"all inventors and ideas deleted\n"
		else 
			status 400
			body "password invalid"
		end
	end

  # create a new idea
  post '/ideas' do
  	json_map = JSON.parse(request.body.read)
  	inventor_in = json_map['inventor']
		
  	begin
			if inventor_in && inventor_in['id']
				if Inventor.exists?(inventor_in['id'])
					my_inventor = Inventor.find(inventor_in['id'])
				elsif Inventor.find_by_attribute("name", inventor_in['name']).nil?
					my_inventor = Inventor.create( :id => inventor_in['id'], :name => inventor_in['name'], :gender => inventor_in['gender'] )
				else
					status 400
					return body "Choose a unique name\n"
				end
			elsif
				inventor_in
				begin
					my_inventor = Inventor.find_by_attribute("name", inventor_in['name'])
					if my_inventor.nil? 
						newName = PersonName.new(inventor_in['name'])
		  			my_inventor = Inventor.create!( :name => inventor_in['name'], :firstName => newName.first, :lastName => newName.last, :gender => inventor_in['gender'] )
					end
				rescue Exception => e
					return body e.inspect + "\n"
					status 400
					return body "Inventor does not have name or gender is incorrect (m/f)\n"
				end
			else
				my_inventor = INVENTOR
			end
		

			json_map.delete('inventor')
			idea = Idea.new(json_map)
	  	idea.inventor = my_inventor
	
	  	idea.save
	    json_out(json_map)
    rescue Exception => e
	  	body e.inspect + "\n"
    	#status 400
  		#body "Idea does not contain a category and/or text\n"
    end
	    
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
		
		Idea.all.each do |idea|
			if idea.inventor.id == params[:id]
				idea.destroy
			end
		end
		
		Inventor.find(params[:id]).destroy
		status 204
		"inventor #{params[:id]} deleted\n"
	end

  run! if app_file == $0
  
end