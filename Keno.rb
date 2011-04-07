require 'date'
require 'set'

class Race
  @@next_race_number = 1
  attr_accessor :winners, :start, :number
  def initialize (number = 1)
    @winners = (1..80).to_a.shuffle![1..20]
    @start = DateTime.now
    @number = number
  end
end

class Ticket
  attr_accessor :choices, :races, :purchase_time, :user_name
  @@payouts = {
    1 => {1 => 3},
    2 => {1 => 1, 2 => 12},
    3 => {2 => 1, 3 => 44},
    4 => {2 => 1, 3 => 4, 4 => 120},
    5 => {3 => 2, 4 => 14, 5 => 640},
    6 => {3 => 1, 4 => 5, 5 => 80, 6 => 1800},
    7 => {3 => 1, 4 => 3, 5 => 12, 6 => 125, 7 => 5000},
    8 => {4 => 2, 5 => 7, 6 => 60, 7 => 675, 8 => 25000},
    9 => {4 => 1, 5 => 5, 6 => 20, 7 => 210, 8 => 2500, 9 => 100000},
    10 => {4 => 1, 5 => 2, 6 => 6, 7 => 50, 8 => 580, 9 => 10000, 10 => 500000}
  }
    
  def initialize(user, choices, races)
    @user_name = user
    @choices = choices
    @races = races
    @purchase_time = DateTime.now
  end
  
  def get_payout(race)
    raise "Invalid ticket!" if @purchase_time > race.start
    correct = race.winners.to_set & @choices.to_set
    @@payouts[@choices.count][correct.size]
  end
end

class Keno
  attr_accessor :races, :tickets
 
  def initialize
    @races = {}
    @current_index = 0
    @tickets = []
  end
  
  def start_race
    race = races[@current_index] =  Race.new
    @current_index += 1
    race
  end
  
  def check_ticket(ticket)
    payout = 0
    ticket.races.each do |r| 
      payout += ticket.get_payout @races[r] unless @races[r].nil?
    end
    payout
  end 
  
  def add_ticket(ticket)
    @tickets.push ticket
  end
end
