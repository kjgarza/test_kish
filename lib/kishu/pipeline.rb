require 'faraday'
require 'logger'

require_relative 'utils'
require_relative 'base'

module Kishu
  class Pipeline 

    def initialize
      @conn = Faraday.new(:url => LOGSTASH_HOST)
      # logger = Logger.new(STDOUT)
      # logger.info 
    end

    def is_ready?
      main  = @conn.get do |req|
        req.url '/_node/stats/pipelines/main'
      end
      return nil unless main.dig("pipelines","main","events","out") == 0
    end

    def is_running?

    end

  end
end

