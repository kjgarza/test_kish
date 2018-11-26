require 'json'
require 'date'
require "faraday"
require 'securerandom'
require 'zlib'
require 'digest'

require_relative 'resolution_event'
require_relative 'client'

module Kishu
  class Report

    include Kishu::Base
    include Kishu::Utils

    def initialize options={}
      set_period 
      generate_header_footer
      @es_client = Client.new()
      @logger = Logger.new(STDOUT)
      @report_id = options[:report_id] ? options[:report_id] : ""
    end

    def report_period options={}
      es_client = Client.new()

      logdate = es_client.get_logdate({aggs_size: 1})
      puts logdate
      Date.parse(logdate)
    end


    def get_events options={}
      logger = Logger.new(STDOUT)
      es_client = Client.new()
      response = es_client.get({aggs_size: options[:aggs_size] || 500, after_key: options[:after_key] ||=""})
      aggs = response.dig("aggregations","doi","buckets")
      x = aggs.map do |agg|
        ResolutionEvent.new(agg,@period).wrap_event 
      end
      after = response.dig("aggregations","doi").fetch("after_key",{"doi"=>nil}).dig("doi")
      logger.info "After_key for pagination #{after}"
      y = {data: x, after: after}
      y
    end

    def push_events options={}
      logger = Logger.new(STDOUT)
      es_client = Client.new()
      response = es_client.get({aggs_size: options[:aggs_size] || 500, after_key: options[:after_key] ||=""})
      aggs = response.dig("aggregations","doi","buckets")
      x = aggs.map do |agg|
        ResolutionEvent.new(agg,{period: @period, report_id: @report_id}).push_event 
      end
      after = response.dig("aggregations","doi").fetch("after_key",{"doi"=>nil}).dig("doi")
      logger.info "After_key for pagination #{after}"
      y = {data: x, after: after}
      y
    end

    def generate_dataset_array
      @datasets = []
      loop do
        response = get_events({after_key: @after ||=""})
        @datasets = @datasets.concat response[:data]
        @after = response[:after]
        break if @after.nil?
      end
    end

    def transverse_dataset_array
      loop do
        response = push_events({after_key: @after ||=""})
        @after = response[:after]
        break if @after.nil?
      end
    end


    def generate_files
      loop do
        response = get_events({after_key: @after ||=""})
        File.open("tmp/datasets-#{SecureRandom.hex}.json","w") do |f|
          response[:data].each do |instance|
            separator = response[:after].nil? ? "" : ","
            f.write(instance.to_json+separator+"\n")
          end
        end
        @after = response[:after]
        break if @after.nil?
      end
    end

    def merge_report    
      generate_files
      system("cat tmp/datasets-* > #{merged_file}")
      report = File.read(merged_file)
      parsed = JSON.parse(report)
      File.open(merged_file,"w") do |f|
        f.write(parsed.to_json)
      end
      puts "Merged Completed"
    end

    def compress_merged_file
        report = File.read(merged_file)
        gzip = Zlib::GzipWriter.new(StringIO.new)
        # gzip << report.delete!("\n").to_json
        gzip << report.to_json
        body = gzip.close.string
        body    
    end

    def encoded
      Base64.strict_encode64(compress_merged_file)
    end

    def checksum
      Digest::SHA256.hexdigest(compress_merged_file)
    end


    def make_report_from_files
      merge_report
      report_compressed
    end

    def make_report options={}
      generate_dataset_array
      get_template
      File.open(merged_file,"w") do |f|
        f.write(get_template.to_json)
      end
    end

    def push_report_resolutions
      fail "You need a report id" if @report_id.nil?
      transverse_dataset_array

    end

    def set_period 
      report_period
      @period = { 
        "begin-date": Date.civil(report_period.year, report_period.mon, 1).strftime("%Y-%m-%d"),
        "end-date": Date.civil(report_period.year, report_period.mon, -1).strftime("%Y-%m-%d"),
      }
    end

    def send_report report_id, options={}
#      clean_tmp 

      # conn = Faraday.new(:url => API_URL)
      # logger = Logger.new(STDOUT)
      # logger.info 
      # compresssed = compress("../../tmp/DataCite-access.log-_#{logdate}.json")
      # conn.post do |req|
      #   req.url '/reports'
      #   req.headers['Content-Type'] = 'json'
      #   req.headers['encoding'] = 'gzip'
      #   req.body = compresssed
      # end

    end

    def report_compressed 
      report = 
      {
        "report-header": get_header,
        gzip: encoded,
        checksum: checksum
      }

      File.open(encoded_file,"w") do |f|
        f.write(report.to_json)
      end
    end

    def get_template 
      {
      "report-header": get_header,
      "report-datasets": @datasets
      }
    end

    def get_header 
      {
        "report-name": "resolution report",
        "report-id": "dsr",
        release: "drl",
        created: Date.today.strftime("%Y-%m-%d"),
        "created-by": "datacite",
        "reporting-period": @period,
        "report-filters": [],
        "report-attributes": [],
        exceptions: [{code: 69,severity: "warning", message: "Report is compressed using gzip","help-url": "https://github.com/datacite/sashimi",data: "usage data needs to be uncompressed"}]
      }
    end

  end
end
