require './Keno.rb'
require './KenoSerializer.rb'

puts "#{DateTime.now} starting KenoRunner"
logger = Logger.new
keno = Keno.new
serializer = KenoSerializer.new
serializer.del_keno
next_race_time = Time.now + 45
puts "First race at #{next_race_time}"
serializer.set_next_race_time next_race_time

while true do  
  if Time.now >= next_race_time then
    puts "Starting race number: #{keno.next_race}"
    keno = serializer.get_keno
    keno.start_race
    serializer.set_keno keno
    next_race_time = Time.now + 300
    serializer.set_next_race_time next_race_time
  end
  sleep 10
  puts "#{DateTime.now} Choosing next number"
  keno = serializer.get_keno
  keno.get_current_race.get_next
  serializer.set_keno keno
end
