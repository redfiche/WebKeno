require 'sinatra'
require 'haml'
require 'sass'
require './keno.rb'
require 'redis'
require 'yaml'
require 'json'
require 'coffee-script'

@@redis = Redis.new(:host => 'localhost', :port => 6379)
@@logger = Logger.new

def get_keno
  serialized_keno = @@redis.get "keno"
  unless serialized_keno.nil?
    keno = YAML::load serialized_keno
  else
    keno = Keno.new
  end
  keno
end

def set_keno(keno)
  data = YAML::dump keno
  @@redis.set "keno", data
end 

get '/' do
  @new_ticket = false
  haml :index
end

get '/keno.js' do
  coffee :keno
end

get '/newTicket.js' do
  coffee :newTicket
end

get '/next_winner.json' do
  keno = get_keno
  @@logger.log "#{keno.inspect}"
  race = keno.get_current_race
  next_choice = race.get_next()
  set_keno keno
  content_type :json
  { :chosen => race.chosen, :current => next_choice}.to_json
end

get '/next_race' do
  keno = get_keno
  keno.start_race
  set_keno keno
end

get '/keno.css' do
  scss :keno
end

get '/newticket' do
  @new_ticket = true
  haml :index
end

post '/newticket' do
  name = params[:name]
  choices = params[:choices].map {|choice| choice.to_i}
  how_many = params[:howMany].to_i
  keno = get_keno
  first_race = keno.next_race
  last_race = first_race + how_many - 1
  races = (first_race .. last_race).to_a
  keno.add_ticket Ticket.new name, choices, races
  set_keno keno
end

get '/status' do
  keno = get_keno
  @race_results = keno.races.map do |race| 
    "Start time: #{race.start} Number: #{race.number} Winners: #{race.winners.sort}"
  end
  
  @ticket_results = keno.tickets.map do |ticket|
    score = keno.check_ticket ticket
    "Name: #{ticket.user_name}, Races: #{ticket.races}, Choices: #{ticket.choices}, Score: #{score}"
  end
  
  haml :status 
end  