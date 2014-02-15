module RedisModel
  class Configurations
    include Singleton

    attr_accessor :redis_url, :app_name, :environment

    def environment
      @environment || (defined?(Rails) ? Rails.env : (ENV['RAILS_ENV'] || ENV['RACK_ENV']))
    end

    def redis_url
      @redis_url || 'redis://localhost:6379'
    end
  end
end
