require 'faraday'
require 'logger'
require 'maremma'
require 'sucker_punch'

require_relative 'utils'
require_relative 'base'
require_relative 'lagotto_job'

module Kishu
  class ResolutionEvent 

    include Kishu::Utils

    def initialize(event, options={})
      @event = event
      @logger = Logger.new(STDOUT)
      @period = options[:period]
    end
    
    def wrap_event
      # puts "------------------ \n"
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
        total_counts_machine: total_machine.empty? ? 0 :  total_machine.dig(0,"doc_count")
      }

    
        @doi = dataset.fetch(:doi,nil)

        data = {}
        instances =[
          {
            "count" => dataset.fetch(:total_counts_regular),
            "access-method" => "regular",
            "metric-type" => "total-resolutions"
          },
          {
            "count" => dataset.fetch(:unique_counts_regular),
            "access-method" => "regular",
            "metric-type" => "unique-resolutions"
          },
          {
            "count" => dataset.fetch(:unique_counts_machine),
            "access-method" => "machine",
            "metric-type" => "unique-resolutions"
          },
          {
            "count" => dataset.fetch(:total_counts_machine),
            "access-method" => "machine",
            "metric-type" => "total-resolutions"
          },
        ]
    
        instances.delete_if {|instance| instance.dig("count") < 1}
  

        instanced = { 
          "dataset-id" => [{"type" => "doi", "value"=> dataset.fetch(:doi,nil)}],
          "performance" => [{
            "period"=> @period,
            "instance"=> instances
          }]
        }
      instanced
    end
    
  
  end
end