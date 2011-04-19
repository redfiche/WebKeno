require 'redis'
require 'yaml'
require 'thread'

class KenoSerializer
  
  def initialize
    @redis = Redis.new(:host => 'localhost', :port => 6379)
    @logger = Logger.new
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
    @@semaphore.synchronize {
      @redis.del "keno"
    }
  end
  
  def set_next_race_time(time)
    yaml_time = YAML::dump time
    @redis.set "next", yaml_time
  end
  
  def get_next_race_time
    next_race = @redis.get "next"
    YAML::load next_race
  end
end
