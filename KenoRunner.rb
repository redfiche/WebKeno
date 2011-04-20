#!/usr/bin/env ruby

require './Keno.rb'
require './KenoSerializer.rb'

first_race = ARGV[0].to_i
race_interval = ARGV[1].to_i
pick_interval = ARGV[2].to_i

puts "#{DateTime.now} starting KenoRunner"
logger = Logger.new 'keno.log'
keno = Keno.new
serializer = KenoSerializer.new
serializer.del_keno
next_race_time = Time.now + first_race
next_pick_time = Time.now + pick_interval
puts "First race at #{next_race_time}"
serializer.set_next_race_time next_race_time
started = false

while true do  
  if Time.now >= next_race_time then
    started = true
    puts "Starting race number: #{keno.next_race}"
    keno = serializer.get_keno
    keno.start_race
    serializer.set_keno keno
    next_race_time = Time.now + race_interval
    serializer.set_next_race_time next_race_time
    next_pick_time = Time.now
  end
  if Time.now >= next_pick_time and started then
    puts "#{DateTime.now} Choosing next number"
    keno = serializer.get_keno
    keno.get_current_race.get_next
    serializer.set_keno keno
    next_pick_time += pick_interval
  end
  sleep 1
end
