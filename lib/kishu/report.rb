require 'json'
require 'date'
require "faraday"
require 'securerandom'
require 'zlib'



module Kishu
  class Report


    def initialise options
      set_period 
      generate_header_footer
      @es_client = Client.new()
      @logger = Logger.new(STDOUT)
    end

    def report_period options={}
      logdate = @es_client.get_logdate({aggs_size: 1})
      puts logdate
      Date.parse(logdate)
    end


    def get_events options={}
      logger = Logger.new(STDOUT)
      # es_client = Client.new()
      response = @es_client.get({aggs_size: options[:aggs_size] || 500, after_key: options[:after_key] ||=""})
      aggs = response.dig("aggregations","doi","buckets")
      x = aggs.map do |agg|
        # wrap_event agg 
        ResolutionEvent.new(agg).wrap_event 
      end
      puts x.size
      # a = x.find_all {|e| e.dig("data-type") == 'dataset' }
      # x = x.delete_if { |hash| hash.empty? }
      # a = x.find_all {|e| e.fetch("data-type","dataset") == 'dataset' }
      # a = x.reject { |e| e.fetch("data-type","dataset") != "dataset" } # returns [1, 3]
      # puts a.size
      after = response.dig("aggregations","doi").fetch("after_key",{"doi"=>nil}).dig("doi")
      logger.info "After_key for pagination #{after}"
      y = {data: x, after: after}
      y
    end

    # def get_paginated
    #   # Cursor.new
    # end

    # def get_all_events
    #   # aggs= get_paginated

    #   # puts aggs.each.lazy

    #   # x = aggs.map do |event|
    #   #   wrap_event event
    #   # end
    #   # x = x.reject { |e| e["data-type"] != "dataset" } # returns [1, 3]
    #   # x
    # end


    def generate_files
      # n =0

      loop do
        response = get_events({after_key: @after ||=""})
        File.open("tmp/datasets-#{SecureRandom.hex}.json","w") do |f|
          response[:data].each do |instance|
            separator = response[:after].nil? ? "" : ","
            f.write(instance.to_json+separator+"\n")
          end
        end
        # break if n == 3
        @after = response[:after]
        break if @after.nil?
        
      end
    end

    def merged_file
      "reports/datacite_resolution_report_#{report_period.strftime("%Y-%m")}.json"
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

    def generate_header_footer
      report_header = '{"report-header": '+get_header.to_json.to_s+',"report-datasets": [ '+"\n"
      
      File.open("tmp/datasets-00-report-header.json","w") do |f|
        f.write(report_header)
      end
      report_footer = ']'+"\n"+'}'
      
      File.open("tmp/datasets-zz99-report-footer.json","w") do |f|
        f.write(report_footer)
      end
    end

    def make_report_2
      # logdate= "2018-04-01"

      merge_report
    end


    def make_report
      merge_report
      # logdate= "2018-04-05"
      # report = {
      #   "report-header": get_header(logdate),
      #   "report-datasets": get_events.dig(:data)
      # }
      
      # File.open("datacite-resolution-report-#{logdate}.json","w") do |f|
      #   f.write(report.to_json)
      # end
    end

    def set_period 
      report_period
      @period = { 
        "begin-date": Date.civil(report_period.year, report_period.mon, 1).strftime("%Y-%m-%d"),
        "end-date": Date.civil(report_period.year, report_period.mon, -1).strftime("%Y-%m-%d"),
      }
    end

    def get_report year_month 
      # logdate= "2018-04-05"
      # set_period 

      # make_report
      make_report_2 
     # clean_tmp 
      # send_report get_header(logdate).dig("report-id"), logdate
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

    def compress file
      report = File.read(file)
      gzip = Zlib::GzipWriter.new(StringIO.new)
      gzip << report.to_json
      body = gzip.close.string
      body
    end

    # def get_header logdate
    # date = Date.parse(logdate)
    # {
    #   "report-name": "resolution report",
    #     "report-id": "dsr",
    #     "release": "rd1",
    #     "created": Date.today.strftime("%Y-%m-%d"),
    #     "created-by": "datacite",
    #     "reporting-period": 
    #     {
    #         "begin-date": Date.civil(date.year, date.mon, 1).strftime("%Y-%m-%d"),
    #         "end-date": Date.civil(date.year, date.mon, -1).strftime("%Y-%m-%d")
    #     },
    #     "report-filters": [ ],
    #     "report-attributes": [ ],
    #     "exceptions": [ ]
    #   }
    # end

    def get_header 
      {
        "report-name": "resolution report",
        "report-id": "dsr",
        "release": "drl",
        "created": Date.today.strftime("%Y-%m-%d"),
        "created-by": "datacite",
        "reporting-period": @period,
        "report-filters": [ ],
        "report-attributes": [ ],
        "exceptions": [{"code": 69,"severity": "warning","message": "Report is compressed using gzip","help-url": "https://github.com/datacite/sashimi","data": "usage data needs to be uncompressed"}]
      }
    end
  end
end
