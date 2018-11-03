require 'json'
require 'date'
require "faraday"

# require_relative 'event'

module Kishu
  module Report

    # include Kishu::Event

    API_URL = "https://api.datacite.org"
    FILENAME = "../../tmp/output.json"


    def get_events
      aggs = all({aggs_size: 100, aggs_after:"false"})
      aggs.map do |event|
        wrap_event event
      end
      aggs
    end

    def get_datasets
    end

    def make_report
      logdate= "2018-04-05"
      report = {
        "report-header": get_header(logdate),
        "report-datasets": get_events
      }
      File.open("../../tmp/DataCite-access.log-_#{logdate}.json","w") do |f|
        f.write(report.to_json)
      end
    end

    def get_report year_month 
      # logdate= "2018-04-05"
      make_report
      # send_report get_header(logdate).dig("report-id"), logdate
    end

    def send_report report_id, options={}
      # conn = Faraday.new(:url => API_URL)
      # logger = Logger.new(STDOUT)
      # logger.info 
      
      # conn.post do |req|
      #   req.url '/reports'
      #   req.headers['Content-Type'] = 'application/json'
      #   req.body = File.open("../../tmp/DataCite-access.log-_#{logdate}.json")
      # end

    end

    def get_header logdate
    date = Date.parse(logdate)
    {
      "report-name": "resolution report",
        "report-id": "dsr",
        "release": "rd1",
        "created": Date.today.strftime("%Y-%m-%d"),
        "created-by": "datacite",
        "reporting-period": 
        {
            "begin-date": Date.civil(date.year, date.mon, 1).strftime("%Y-%m-%d"),
            "end-date": Date.civil(date.year, date.mon, -1).strftime("%Y-%m-%d")
        },
        "report-filters": [ ],
        "report-attributes": [ ],
        "exceptions": [ ]
      }
    end
  end
end
