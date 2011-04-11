require 'sinatra'
require 'haml'
require 'sass'
require './keno.rb'
require 'active_support'
require 'redis'
require 'yaml'

@@redis = Redis.new(:host => 'localhost', :port => 6379)

def get_keno
  serialized_keno = @@redis.get "keno"
  unless serialized_keno.nil?
    keno = YAML::load serialized_keno
  else
    keno = Keno.new
  end
  File.open("keno.log", 'a') {|f| f.write("#{Time.now} #{keno.inspect} \n")}
  keno
end

def set_keno(keno)
  data = YAML::dump keno
  @@redis.set "keno", data
end 

get '/' do
  keno = get_keno
  @race = keno.start_race
  set_keno keno
  @new_ticket = false
  haml :index
end

get '/keno.css' do
  scss :keno
end

get '/newticket' do
  @new_ticket = true
  haml :index
end

post '/newticket' do
  name = params[:user]
  choices = params[:choices]
  keno = get_keno
  keno.add_ticket Ticket.new name, choices, []
  set_keno keno
end

get '/status' do
  keno = get_keno
  @race_results = keno.races.map do |race| 
    File.open("keno.log", 'a') {|f| f.write("#{Time.now} #{race.inspect}")}
    "Start time: #{race.start} Number: #{race.number} Winners: #{race.winners}"
  end
  
  @ticket_results = keno.tickets.map do |ticket|
    "Name: #{ticket.user_name} Races: #{ticket.races} Choices: #{ticket.choices}"
  end
  
  haml :status
  
end  