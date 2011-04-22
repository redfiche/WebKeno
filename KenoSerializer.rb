require 'redis'
require 'yaml'
require 'thread'
require 'logger'

class KenoSerializer
  
  def initialize
    @redis = Redis.new(:host => 'localhost', :port => 6379)
    @logger = ::Logger.new 'keno.log'
  end
  
  def get_keno
    serialized_keno = @redis.get "keno"
    unless serialized_keno.nil?
      keno = YAML::load serialized_keno
    else
      keno = Keno.new
    end
    keno
  end

  def set_keno(keno)
    data = YAML::dump keno
    @redis.set "keno", data
  end 
  
  def del_keno
     @redis.del "keno"
  end
  
  def set_next_race_time(time)
    yaml_time = YAML::dump time
    @redis.set "next", yaml_time
  end
  
  def get_next_race_time
    next_race = @redis.get "next"
    YAML::load(next_race) unless next_race.nil?
  end
  
  def add_user(user)
    users = @redis.get "users"
    users = YAML::load(users) unless users.nil?
    if users.nil? then
      users = Set.new
    end
    users.add user
    @redis.set "users", YAML::dump(users)
    the_user = @redis.get user
    if the_user.nil? then 
      @redis.set user, YAML::dump([])
    end
  end
  
  def add_ticket(ticket)
    add_user ticket.user_name
    tickets = YAML::load(@redis.get(ticket.user_name))
    tickets.push ticket
    @redis.set ticket.user_name, YAML::dump(tickets)
  end
  
  def get_score(tickets)
    keno = get_keno
     tickets.inject(0) {|score, ticket| score += keno.check_ticket(ticket)}
  end
   
  def get_user_scores
    users = YAML::load(@redis.get "users")
    scores = users.inject(Hash.new) do |hsh, user| 
      rawTickets = @redis.get user
      tickets = YAML::load rawTickets
      score = get_score tickets
      hsh.merge!({user => score})
    end
    scores.sort_by { |k,v| -v}
  end
end
