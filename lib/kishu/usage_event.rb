require 'faraday'
require 'logger'
require 'maremma'

require_relative 'utils'
require_relative 'base'

module Kishu
  class UsageEvent 

    API_URL = "https://api.datacite.org"
    
    def wrap_event(event, options={})
      totale_investigations = event.dig("totale").fetch("buckets", [])
      unique_investigations = event.dig("unique").fetch("buckets", [])
    
      unique_regular_investigations = unique_investigations.find_all {|access_method| access_method.fetch('key',"").match('regular') }
      unique_machine_investigations = unique_investigations.find_all {|access_method| access_method.fetch('key',"").match('machine') }
      total_regular_investigations  = totale_investigations.find_all {|access_method| access_method.fetch('key',"").match('regular') }
      total_machine_investigations  = totale_investigations.find_all {|access_method| access_method.fetch('key',"").match('machine') }

      totale_requests = event.dig("totale").fetch("buckets", [])
      unique_requests = event.dig("unique").fetch("buckets", [])
    
      unique_regular_requests = unique_requests.find_all {|access_method| access_method.fetch('key',"").match('regular') }
      unique_machine_requests = unique_requests.find_all {|access_method| access_method.fetch('key',"").match('machine') }
      total_regular_requests  = totale_requests.find_all {|access_method| access_method.fetch('key',"").match('regular') }
      total_machine_requests  = totale_requests.find_all {|access_method| access_method.fetch('key',"").match('machine') }

      dataset = { 
        doi: event.dig("key","doi"), 
        unique_counts_regular_investigations: unique_regular_investigations.empty? ? 0 : unique_regular_investigations.size,
        unique_counts_machine_investigations: unique_machine_investigations.empty? ? 0 : unique_machine_investigations.size,
        total_counts_regular_investigations: total_regular_investigations.empty? ? 0 : total_regular_investigations.dig(0,"doc_count"),
        total_counts_machine_investigations: total_machine_investigations.empty? ? 0:  total_machine_investigations.dig(0,"doc_count"),
        unique_counts_regular_requests: unique_regular_requests.empty? ? 0 : unique_regular_requests.size,
        unique_counts_machine_requests: unique_machine_requests.empty? ? 0 : unique_machine_requests.size,
        total_counts_regular_requests: total_regular_requests.empty? ? 0 : total_regular_requests.dig(0,"doc_count"),
        total_counts_machine_requests: total_machine_requests.empty? ? 0:  total_machine_requests.dig(0,"doc_count")
      }

      # conn = Faraday.new(:url => API_URL)
      logger = Logger.new(STDOUT)
      logger.info event.fetch("doc_count")
      
      logger.info dataset

      doi = dataset.fetch(:doi,nil)

      data = get_metadata doi

      instances =[
        {
          "count": dataset[:total_counts_regular_investigations],
          "access-method": "regular",
          "metric-type": "total_dataset_investigations"
        },
        {
          "count": dataset[:unique_counts_regular_investigations],
          "access-method": "regular",
          "metric-type": "unique_dataset_investigations"
        },
        {
          "count": dataset[:unique_counts_machine_investigations],
          "access-method": "machine",
          "metric-type": "unique_dataset_investigations"
        },
        {
          "count": dataset[:total_counts_machine_investigations],
          "access-method": "machine",
          "metric-type": "total_dataset_investigations"
        },
        {
          "count": dataset[:total_counts_regular],
          "access-method": "regular",
          "metric-type": "total_dataset_requests"
        },
        {
          "count": dataset[:unique_counts_regular],
          "access-method": "regular",
          "metric-type": "unique_dataset_requests"
        },
        {
          "count": dataset[:unique_counts_machine],
          "access-method": "machine",
          "metric-type": "unique_dataset_requests"
        },
        {
          "count": dataset[:total_counts_machine],
          "access-method": "machine",
          "metric-type": "total_dataset_requests"
        }
      ]
      instances.delete_if {|instance| instance.dig(:count) <= 0}
      attributes = data.dig("data","attributes")
      resource_type = attributes.fetch("resource-type-id",nil).nil? ? "dataset" : attributes.fetch("resource-type-id",nil)

      instanced = { 
        "dataset-id" => [{type: "doi", value: dataset.fetch(:doi,nil)}],
        "data-type" => resource_type,
        "yop" => attributes.fetch("published",nil),
        "uri" => attributes.fetch("identifier",nil),
        "publisher" => attributes.fetch("container-title",nil),
        "dataset-title": attributes.fetch("title",nil),
        "publisher-id": [{
          "type" => "client-id",
          "value" => attributes.fetch("data-center-id",nil)
        }],
        "dataset-dates": [{
          "type" => "pub-date",
          "value" => attributes.fetch("published",nil)
        }],
        "dataset-contributors": attributes.fetch("author",[]).map { |a| get_authors(a) },
        "platform" => attributes.fetch("data-center-id",nil),
        "performance" => [{
          "period" => @period,
          "instance" => instances
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

    def get_metadata doi
      json = Maremma.get "#{API_URL}/works/#{doi}"
      logger.info json.status
      return {} unless json.status == 200 
      logger.info "Success on getting metadata for #{doi}"
      JSON.parse(json.body)
    end
  end
end
