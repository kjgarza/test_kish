require 'faraday_middleware'
require 'faraday_middleware/aws_sigv4'
require 'logger'

require_relative 'utils'
require_relative 'base'

module Kishu
  class Client 

    def initialize
      # @client = Elasticsearch::Client.new host: ES_HOST, transport_options: { request: { timeout: 3600, open_timeout: 3600 } }
      # @client
      if ES_HOST == "localhost:9200" || ES_HOST == "elasticsearch:9200"
        @client = Elasticsearch::Client.new(host: ES_HOST, user: "elastic", password: ELASTIC_PASSWORD, transport_options: { request: { timeout: 3600, open_timeout: 3600 }}) do |f|
          f.adapter Faraday.default_adapter
        end
      else
          @client = Elasticsearch::Client.new(host: ES_HOST, port: '80', scheme: 'http') do |f|
            f.request :aws_sigv4,
              service: 'es',
              region: AWS_REGION,
              access_key_id: AWS_ACCESS_KEY_ID,
              secret_access_key: AWS_SECRET_ACCESS_KEY
            f.adapter Faraday.default_adapter
          end
      end
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
        index: ES_INDEX
        )
      x
    end

    def is_empty?
      return true unless get
      nil
    end

    def clear_index
      @client.indices.delete index: ES_INDEX
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

