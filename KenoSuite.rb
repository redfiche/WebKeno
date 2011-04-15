require './Keno.rb'
require 'minitest/autorun'
require 'set'
require 'json'

class TestRace < MiniTest::Unit::TestCase
  def setup
    @race = Race.new
  end
  
  def test_that_there_are_twenty_winners
    assert_equal 20, @race.winners.count
  end
  
  def test_that_there_are_no_duplicates
    assert_equal @race.winners.count, @race.winners.to_set.size
  end
  
  def test_equals
    d = Date.new
    winners = [12,14,16,24,33,54,65,69,]
  end
end

class Race
  attr_accessor :winners, :start
end

class Ticket
  def payouts
    @@payouts
  end
end

class TestTicket < MiniTest::Unit::TestCase    
  def setup
    @all_numbers = (1..80).to_a.shuffle!
    @ticket_numbers = @all_numbers.take(10)
  end
  
  def get_spots
    data = []
    (1..10).each do |spot_count|
      current = @ticket_numbers.take(spot_count)
      (0..spot_count).each do |hit_count|
        spots = @ticket_numbers.take(hit_count)
        spots.concat @all_numbers[80 - (spot_count - hit_count) .. 80]
        spot_data = {spot_count: spot_count, hit_count: hit_count, spots: spots}
        yield spot_data
      end
    end
  end
  
  def test_all_payouts
    #puts "#{ticket_numbers}"
    get_spots do |spot_data| 
      ticket = Ticket.new "user", @ticket_numbers.take(spot_data[:spot_count]), [0]
      race = Race.new
      race.winners = spot_data[:spots]
      payout = ticket.get_payout(race)
      #puts "Spots:#{spot_data[:spot_count]}  #{spot_data[:hit_count]} #{payout}"
      spots = spot_data[:spot_count]
      hits = spot_data[:hit_count]
      assert_equal ticket.payouts[spots][hits], payout
    end
  end
  
  def test_invalid_ticket
    race = Race.new
    race.start = DateTime.now - 10
    ticket = Ticket.new "user", [8,9,0], [0]
    assert_raises(RuntimeError) {ticket.get_payout(race)}
  end
    
end

class TestKeno < MiniTest::Unit::TestCase
  def test_check_ticket
    mock = MiniTest::Mock.new
  
    race1 = Race.new
    race2 = Race.new
    race3 = Race.new
  
    mock.expect :races, [0,1,2]
    mock.expect :get_payout, 1, [race1]
   
    k = Keno.new
    k.races = [race1, race2, race3]
  
    assert_equal 3, k.check_ticket(mock)
    
    mock.verify
  end
  
  def test_equals
    k = Keno.new
    j = Keno.new
    r = Race.new
    ticket = Ticket.new "user", [8,9,0], [0]
    k.races = [r]
    j.races = [r]
    k.tickets = [ticket]
    j.tickets = [ticket]
    assert_equal j, k
  end
  
  def test_to_json
    k = Keno.new
    ticket = Ticket.new "user", [8,9,0], [0]
    k.add_ticket ticket
    k.start_race
    assert_equal k, JSON.parse(k.to_json)
  end
end

    
    