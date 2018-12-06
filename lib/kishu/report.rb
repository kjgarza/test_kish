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
      @es_client = Client.new()
      @logger = Logger.new(STDOUT)
      @report_id = options[:report_id] ? options[:report_id] : ""
      @total = 0
      @aggs_size = options[:aggs_size] 
      @chunk_size = options[:chunk_size]
      @after = options[:after_key] ||=""
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
      response = es_client.get({aggs_size: @aggs_size || 500, after_key: options[:after_key] ||=""})
      aggs = response.dig("aggregations","doi","buckets")
      x = aggs.map do |agg|
        ResolutionEvent.new(agg,{period: @period, report_id: @report_id}).wrap_event
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
        @total += @datasets.size
        generate_chunk_report if @datasets.size > @chunk_size
        break if @after.nil?
      end
    end

    def compress report
      # report = File.read(hash)
      gzip = Zlib::GzipWriter.new(StringIO.new)
      string = report.to_json
      gzip << string
      body = gzip.close.string
      body
    end

 
    def generate_chunk_report
      # puts get_template
      # LagottoJob.perform_async(get_template(@datasets))
      file = merged_file #+ 'after_key_' + @after
      File.open(file,"w") do |f|
        f.write(JSON.pretty_generate get_template)
      end
      send_report get_template
      @datasets = []
    end

    def make_report options={}
      generate_dataset_array
      @logger.info  "#{LOGS_TAG} Month of #{@period.dig("begin-date")} sent to Hub in report #{@uid} with stats for #{@total} datasets"
    end


    def set_period 
      report_period
      @period = { 
        "begin-date": Date.civil(report_period.year, report_period.mon, 1).strftime("%Y-%m-%d"),
        "end-date": Date.civil(report_period.year, report_period.mon, -1).strftime("%Y-%m-%d"),
      }
    end

    def send_report report, options={}
      uri = HUB_URL+'/reports'   
      puts uri

      headers = {
        content_type: "application/gzip",
        content_encoding: 'gzip',
        accept: 'gzip'
      }
      
      body = compress(report)
      n = 0
      loop do
        request = Maremma.post(uri, data: body,
          bearer: ENV['HUB_TOKEN'],
          headers: headers,
          timeout: 100)

        @uid = request.body.dig("data","report","id")
        @logger.info "#{LOGS_TAG} Hub response #{request.status} for Report finishing in #{@after}"
        @logger.info "#{LOGS_TAG} Hub response #{@uid} for Report finishing in #{@after}"
        n += 1
        break if request.status == 201
        fail "#{LOGS_TAG} Too many attempts were tried to push this report" if n > 1
        sleep 1
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
