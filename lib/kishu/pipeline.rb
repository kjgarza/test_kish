require 'faraday'
require 'logger'
require 'json'

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
      response = JSON.parse(main.body)
      return nil unless response.dig("pipelines","main","events","out") == 0
    end

    def status?
      main  = @conn.get do |req|
        req.url '/_node/stats/pipelines/main'
        req.options.timeout = 200
      end
      response = JSON.parse(main.body)
      puts "Pipeline Status"
      puts response.dig("pipelines","main","events") 
      puts response.dig("pipelines","main","events","in")
      puts response.dig("pipelines","main","events","out")
    end

  end
end

