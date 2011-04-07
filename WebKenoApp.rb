require 'sinatra'
require 'haml'
require 'sass'
require './keno.rb'
require 'json'
require 'redis'

@@redis = Redis.new(:host => 'localhost', :port => 6379)

def get_keno
  keno_json = @@redis.get "keno"
  unless keno_json.nil?
    keno = JSON.parse keno_json
  else
    keno = Keno.new
  end
  keno
end

def set_keno(keno)
  data = keno.to_json
  @@redis.set "keno", data
end 

get '/' do
  keno = get_keno
  File.open("keno.log", 'a') {|f| f.write("#{Time.now} #{keno.inspect} \n")}
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
  File.open("keno.log", 'a') {|f| f.write("#{Time.now} #{keno.inspect} \n")}
  @race_results = keno.races.inject([]) do |results, race| 
    results.push("Start time: #{race.start} Number: #{race.number} Winners: #{race.winners}")
  end
  
  @ticket_results = keno.tickets.inject([]) do |results, ticket|
    results.push("Name: #{ticket.user_name} Races: #{ticket.races} Choices: #{ticket.choices}")
  end
  
  haml :status
  
end  