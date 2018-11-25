require 'faraday'
require 'logger'

require_relative 'utils'
require_relative 'base'

module Kishu
  class Client 

    def initialize
      @client = Elasticsearch::Client.new host: 'localhost:9200', transport_options: { request: { timeout: 3600, open_timeout: 3600 } }
      @client
    end


    def get options={}

      x =@client.search(body:{
          size: options[:size] ||= 0,
          query: {
            query_string: {
              query: "*"
            }
          },
          aggregations: aggregations(options)
        },
        index: "resolutions"
        )
      x
    end

    def is_empty?
      return true unless get
      nil
    end

    def clear_index
      @client.indices.delete index: 'resolutions'
      puts "Resolutions index has been deleted"
    end


    def get_logdate options={}
      @client.search(body:{
          size: 1,
          query: {
            query_string: {
              query: "*"
            }
          },
          aggregations: aggregations(options)
        },
        index: "resolutions"
        ).dig("hits","hits",0,"_source","logdate")
    end

    def aggregations options={}
      {
        doi: {composite: {
          sources: [{doi: {terms: {field: :doi	}}}],
          after: { doi: options.fetch(:after_key,"")},
          size: options[:aggs_size]
          },
          aggs: {
            unique: {terms: {field: "unique_usage"}},
            totale: {terms: {field: "total_usage"	}}
          }
        }
      }
    end

  end
end

