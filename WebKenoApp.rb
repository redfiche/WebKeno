require 'sinatra'
require 'haml'
require 'sass'
require './keno.rb'
require 'json'
require 'coffee-script'
require './KenoSerializer.rb'

@@ks = KenoSerializer.new
@@logger = Logger.new 'keno.log'

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
  keno = @@ks.get_keno
  race = keno.get_current_race
  if race.nil? then return nil end
  content_type :json
  { :race_number => race.number, :chosen => race.chosen}.to_json
end

get '/next_race_time.json' do
  time = @@ks.get_next_race_time
  if time.nil? then return nil end
  content_type :json
  { :hours => time.hour, :minutes => time.min, :seconds => time.sec}.to_json
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
  keno = @@ks.get_keno
  first_race = keno.nil? ? 0 : keno.next_race
  last_race = first_race + how_many - 1
  races = (first_race .. last_race).to_a
  @@ks.add_ticket Ticket.new name, choices, races
end

get '/status' do
  keno = @@ks.get_keno
  @race_results = keno.races.map do |race| 
    "Start time: #{race.start} Number: #{race.number} Winners: #{race.winners.sort}"
  end
  
  results = {}
  users = @@ks.get_users
  users.each do |name, tickets|
    score = tickets.inject(0) {|sum, ticket| sum + keno.check_ticket(ticket)}
    results.merge!({:name => name, :score => score})
  end
  results = results.sort_by {|result| result.score}
  
  @ticket_results = results.map do |result|
    "Name: #{result.name}, Score: #{result.score}"
  end
  
  haml :status 
end  
