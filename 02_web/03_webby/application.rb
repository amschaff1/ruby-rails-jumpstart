
require 'bundler/setup'
require 'rubygems'
require 'sinatra/base'
require 'sinatra/respond_to'
require 'padrino-helpers'
require 'rack/csrf'
require 'rack/methodoverride'
require 'supermodel'
require 'haml'
require 'open-uri'
require 'json'

# ----------------------------------------------------
# models
# ----------------------------------------------------
class Location < SuperModel::Base
  include SuperModel::RandomID
  #attributes :name, :lat, :lon
  validates_presence_of :name
  validates :lat, :presence=>true, :numericality => true
  validates :lon, :presence=>true, :numericality => true
end

class DuckDuckGoQuery < SuperModel::Base
	include SuperModel::RandomID
	#attributes :name, :text
	attributes :name, :text
	validates_presence_of :name
end

# ----------------------------------------------------
# web app
# ----------------------------------------------------
class Webby < Sinatra::Base
  register Sinatra::RespondTo                                                   # routes .html to haml properly
  register Padrino::Helpers                                                     # enables link and form helpers

  set :views, File.join(File.dirname(__FILE__), 'views')                        # views directory for haml templates
  set :public_directory, File.dirname(__FILE__) + 'public'                      # public web resources (images, etc)

  configure do                                                                  # use rack csrf to prevent cross-site forgery
    use Rack::Session::Cookie, :secret => "in a real application we would use a more secure cookie secret"
    use Rack::Csrf, :raise => true
  end

  helpers do                                                                    # csrf link/tag helpers
    def csrf_token
      Rack::Csrf.csrf_token(env)
    end

    def csrf_tag
      Rack::Csrf.csrf_tag(env)
    end
  end

  # --- Core Web Application : index ---
  get '/' do
    haml :'index', :layout => :application
  end
  
  # --- Core Web Application : about ---
  get '/about' do
  	haml :'about', :layout => :application
	end

  # --- Core Web Application : locations ---
  get '/locations/?' do
    @locations = Location.all
    haml :'locations/index', :layout => :application
  end

  get '/locations/new' do
    @location = Location.new
    haml :'locations/edit', :layout => :application
  end

  get '/locations/:id' do
    @location = Location.find(params[:id])
    haml :'locations/show', :layout => :application
  end

  get '/locations/:id/edit' do
    @location = Location.find(params[:id])
    @action   = "/locations/#{params[:id]}/update"
    haml :'locations/edit', :layout => :application
  end

  post '/locations/?' do
    @location = Location.new(params[:location])
    if @location.valid?
    	@location.save
  		redirect to('/locations/' + @location.id)
		else
			status 400
    	raise 'The location is not valid'
  	end
  end

  post '/locations/:id/update' do
    @location = Location.find(params[:id])
    @location.update_attributes!(params[:location])
    redirect to('/locations/' + @location.id)
  end

  post '/locations/:id/delete' do
    @location = Location.find(params[:id])
    @location.destroy
    redirect to('/locations')
  end
  
  # --- Core Web Application : duckduckgo queries ---
  get '/duckduckgo_queries/?' do
    @queries = DuckDuckGoQuery.all
    haml :'duckduckgo_queries/index', :layout => :application
  end

  get '/duckduckgo_queries/new' do
    @query = DuckDuckGoQuery.new
    haml :'duckduckgo_queries/edit', :layout => :application
  end

  get '/duckduckgo_queries/:id' do
    @query = DuckDuckGoQuery.find(params[:id])
    haml :'duckduckgo_queries/show', :layout => :application
  end

  get '/duckduckgo_queries/:id/edit' do
    @query = DuckDuckGoQuery.find(params[:id])
    @action   = "/duckduckgo_queries/#{params[:id]}/update"
    haml :'duckduckgo_queries/edit', :layout => :application
  end

  post '/duckduckgo_queries/?' do
    @query = DuckDuckGoQuery.new(params[:duck_duck_go_query])
    @query.text = ""
    
    if @query.valid?
	    query_url = "http://api.duckduckgo.com/?format=json&pretty=1&q=" + URI.escape(@query.name)
	    object = open(query_url) do |v|
	    	input = v.read
	    	JSON.parse(input)
	  	end
	  	object['RelatedTopics'].each do |rt|
	  		@query.text += "#{rt['Text']}"
			end
   
    	@query.save
  		redirect to('/duckduckgo_queries/' + @query.id)
		else
			status 400
    	raise 'The query is not valid'
  	end
  end

  post '/duckduckgo_queries/:id/update' do
    @query = DuckDuckGoQuery.find(params[:id])
    @query.update_attributes!(params[:duck_duck_go_query])
    redirect to('/duckduckgo_queries/' + @query.id)
  end

  post '/duckduckgo_queries/:id/delete' do
    @query = DuckDuckGoQuery.find(params[:id])
    @query.destroy
    redirect to('/duckduckgo_queries')
  end  

  # --- Core Web Application : twitter queries ---
  # TODO

  run! if app_file == $0
end
