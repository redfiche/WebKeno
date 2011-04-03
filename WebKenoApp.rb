require 'sinatra'
require 'haml'
require 'sass'
require './keno.rb'

keno = Keno.new

get '/' do
  @race = keno.start_race
  haml :index
end

get '/keno.css' do
  puts 'getting css'
  scss :keno
end