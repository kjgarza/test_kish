require 'faraday'
require 'logger'
require 'maremma'

require_relative 'utils'
require_relative 'base'

module Kishu
  class ResolutionEvent 

    API_URL = "https://api.datacite.org"

    def initialise event
      @event = event
      @logger = Logger.new(STDOUT)
      # @conn = Faraday.new(:url => API_URL)
    end
    
    def wrap_event
      puts "------------------ \n"
      totale = @event.dig("totale").fetch("buckets", [])
      # puts @event.dig("unique").fetch("buckets", nil)
      unique = @event.dig("unique").fetch("buckets", [])
      # puts unique[1].dig('key')
    
      unique_regular = unique.find_all {|access_method| access_method.fetch('key',"").match('regular') }
      unique_machine = unique.find_all {|access_method| access_method.fetch('key',"").match('machine') }
      total_regular  = totale.find_all {|access_method| access_method.fetch('key',"").match('regular') }
      total_machine  = totale.find_all {|access_method| access_method.fetch('key',"").match('machine') }

      dataset = { 
        doi: @event.dig("key","doi"), 
        unique_counts_regular: unique_regular.empty? ? 0 : unique_regular.size,
        unique_counts_machine: unique_machine.empty? ? 0 : unique_machine.size,
        total_counts_regular: total_regular.empty? ? 0 : total_regular.dig(0,"doc_count"),
        total_counts_machine: total_machine.empty? ? 0:  total_machine.dig(0,"doc_count")
      }

    
      # conn = Faraday.new(:url => API_URL)
      logger = Logger.new(STDOUT)
      logger.info @event.fetch("doc_count")
      
      # arr = dois.map do |dataset| 
        logger.info dataset
        doi = dataset.fetch(:doi,nil)
        # json = conn.get "/works/#{doi}"
        # json = conn.get do |req|
        #   req.url "/works/#{doi}"
        #   req.options.timeout = 50           # open/read timeout in seconds
        #   req.options.open_timeout = 20      # connection open timeout in seconds
        # end
        # json = Maremma.get "#{API_URL}/works/#{doi}"
        # logger.info json.status

        # return {} unless json.status == 200 
        # logger.info "Success on getting metadata for #{doi}"
        # data = JSON.parse(json.body)
        # data = json.body
        data = {}
        instances =[
          {
            count: dataset.fetch(:total_counts_regular),
            "access-method": "regular",
            "metric-type": "total-resolutions"
          },
          {
            count: dataset.fetch(:unique_counts_regular),
            "access-method": "regular",
            "metric-type": "unique-resolutions"
          },
          {
            count: dataset.fetch(:unique_counts_machine),
            "access-method": "machine",
            "metric-type": "unique-resolutions"
          },
          {
            count: dataset.fetch(:total_counts_machine),
            "access-method": "machine",
            "metric-type": "total-resolutions"
          },
        ]
    
        instances.delete_if {|instance| instance.dig(:count) <= 0}
        attributes = {} #data.dig("data","attributes")
        resource_type = "" #attributes.fetch("resource-type-id",nil).nil? ? "dataset" : attributes.fetch("resource-type-id",nil)

        instanced = { 
          "dataset-id" => [{type: "doi", value: dataset.fetch(:doi,nil)}],
          # "data-type" => resource_type,
          # yop: attributes.fetch("published",nil),
          # uri: attributes.fetch("identifier",nil),
          # publisher: attributes.fetch("container-title",nil),
          # "dataset-title": attributes.fetch("title",nil),
          # "publisher-id": [{
          #   type: "client-id",
          #   value: attributes.fetch("data-center-id",nil)
          # }],
          # "dataset-dates": [{
          #   type: "pub-date",
          #   value: attributes.fetch("published",nil)
          # }],
          # "dataset-contributors": attributes.fetch("author",[]).map { |a| get_authors(a) },
          # platform: "datacite",
          performance: [{
            period: @period,
            instance: instances
          }]
        }
        logger.info instanced

      instanced
    end
    
    
    def get_authors author
      if (author.key?("given") && author.key?("family"))
        { type: "name",
          value: author.fetch("given",nil)+" "+author.fetch("family",nil) }
        elsif author.key?("literal")
          { type: "name",
            value: author.fetch("literal",nil) }
        else 
          { type: "name",
            value: "" }
      end
    end

    def get_metadata
        # json = conn.get "/works/#{doi}"
        json = @conn.get do |req|
          req.url "/works/#{doi}"
          req.options.timeout = 50           # open/read timeout in seconds
          req.options.open_timeout = 200      # connection open timeout in seconds
        end
        # json = Maremma.get "#{API_URL}/works/#{doi}"
        logger.info json.status

        return {} unless json.status == 200 
        logger.info "Success on getting metadata for #{doi}"
        data = JSON.parse(json.body)
        data = json.body
    end
  
  end
end
