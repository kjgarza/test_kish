require 'faraday'
require 'logger'

require_relative 'utils'
require_relative 'base'

module Kishu
  module Event 

    API_URL = "https://api.datacite.org"

    def all options={}
      __elasticsearch__ = Elasticsearch::Client.new host: 'localhost:9200', transport_options: { request: { timeout: 3600, open_timeout: 3600 } }
      x =__elasticsearch__.search(body:{
          size: options[:size] || 0,
          query: {
            query_string: {
              query: "*"
            }
          },
          aggregations: aggregations(options)
        },
        index: "resolutions"
        )
      puts x
      x.dig("aggregations")
    end
    
    def aggregations options={}
      {
        doi: {composite: {
          sources: [{doi: {terms: {field: :doi	}}}],
          size: options[:aggs_size] || 102
          },
          aggs: {
            unqiue: {terms: {field: "unique_usage"}},
            totale: {terms: {field: "total_usage"	}}
          }
        }
      }
    end
    
    
    def wrap_event(event)
      total = event.get("[dois][buckets]")
    
      dois = total.map do |dataset| 
    
        unique_regular = dataset["access_method"]["buckets"].find {|access_method| access_method['key'] == 'regular' }
        unique_machine = dataset["access_method"]["buckets"].find {|access_method| access_method['key'] == 'machine' }
        total_regular  = dataset["total"]["buckets"].find {|access_method| access_method['key'] == 'regular' }
        total_machine  = dataset["total"]["buckets"].find {|access_method| access_method['key'] == 'machine' }
    
        puts dataset["key"]
        { 
          doi: dataset["key"], 
          unique_counts_regular: unique_regular.nil? ? 0 : unique_regular["unqiue"]["value"],
          unique_counts_machine: unique_machine.nil? ? 0 : unique_machine["unqiue"]["value"],
          total_counts_regular: total_regular.nil? ? 0 : total_regular["doc_count"],
          total_counts_machine: total_machine.nil? ? 0:  total_machine["doc_count"]
        }
      end
    
      conn = Faraday.new(:url => API_URL)
      logger = Logger.new(STDOUT)
      logger.info total.size
      
      arr = dois.map do |dataset| 
        logger.info dataset
        doi = dataset[:doi]
        json = conn.get "/works/#{doi}"
        next unless json.success?
        logger.info "Success on getting metadata for #{doi}"
        data = JSON.parse(json.body)
    
        instances =[
          {
            count: dataset[:total_counts_regular],
            "access-method": "regular",
            "metric-type": "total-resolutions"
          },
          {
            count: dataset[:unique_counts_regular],
            "access-method": "regular",
            "metric-type": "unique-resolutions"
          },
          {
            count: dataset[:unique_counts_machine],
            "access-method": "machine",
            "metric-type": "unique-resolutions"
          },
          {
            count: dataset[:total_counts_machine],
            "access-method": "machine",
            "metric-type": "total-resolutions"
          },
        ]
    
        instances.delete_if {|instance| instance.dig(:count) <= 0}
    
        attributes = data.dig("data","attributes")
        { 
          "dataset-id": [{type: "doi", value: attributes["doi"]}],
          "data-type": attributes["resource-type-id"],
          yop: attributes["published"],
          uri: attributes["identifier"],
          publisher: attributes["container-title"],
          "dataset-title": attributes["title"],
          "publisher-id": [{
            type: "client-id",
            value: attributes["data-center-id"]
          }],
          "dataset-dates": [{
            type: "pub-date",
            value: attributes["published"]
          }],
          "dataset-contributors": attributes["author"].map { |a| get_authors(a) },
          tags:["_dc_meta"],
          platform: "datacite",
          performance: [{
            period: {
              "begin-date": "",
              "end-date": "",
            },
            instance: instances
          }]
        }
      end
    
      # arr.map! do |instance|
      #   LogStash::Event.new(instance)
      # end
    
      arr
    end
    
    
    def get_authors author
      if (author.key?("given") && author.key?("family"))
        { type: "name",
          value: author["given"]+" "+author["family"] }
        elsif author.key?("literal")
          { type: "name",
            value: author["literal"] }
        else 
          { type: "name",
            value: "" }
      end
    end
  
  end
end
