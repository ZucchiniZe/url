require 'guillotine'
require 'redis'
require 'haml'

module Katana
    class App < Guillotine::App
      # use redis adapter with redistogo
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)
      adapter = Guillotine::RedisAdapter.new REDIS
      set :service => Guillotine::Service.new(adapter, strip_query: false,
                                              :strip_anchor => false)

      get '/' do
        haml :index
      end

      if ENV['TWEETBOT_API']
        # experimental (unauthenticated) API endpoint for tweetbot
        get '/api/create/?' do
          status, head, body = settings.service.create(params[:url], params[:code])

          if loc = head['Location']
            "#{File.join("http://", request.host, loc)}"
          else
            500
          end
        end
      end
    end
end
