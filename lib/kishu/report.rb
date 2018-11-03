require 'json'
require 'date'
require "faraday"

# require_relative 'event'

module Kishu
  module Report

    # include Kishu::Event

    FILENAME = "../../tmp/output.json"


    def get_events options={}
      es_client = Client.new()
      aggs = es_client.get({aggs_size: options[:aggs_size] || 100, after_key:""})
      # puts aggs.class
      x = aggs.map do |event|
        wrap_event event
      end
      x = x.reject { |e| e["data-type"] != "dataset" } # returns [1, 3]
      x
    end

    def get_all_events
      aggs= get_paginated
      x = aggs.map do |event|
        new_event = wrap_event event
        puts new_event
        next if new_event.dig("data-type") != "dataset"
        new_event
      end
      x
    end

    def make_report
      logdate= "2018-04-05"
      report = {
        "report-header": get_header(logdate),
        "report-datasets": get_events
      }
      File.open("DataCite-access.log-_#{logdate}.json","w") do |f|
        f.write(report.to_json)
      end
    end

    def set_period year_month
      # PERIOD = { 
      #   "begin-date": Date.civil(date.year, date.mon, 1).strftime("%Y-%m-%d"),
      #   "end-date": Date.civil(date.year, date.mon, -1).strftime("%Y-%m-%d"),
      # }
      @period = {"begin-date": "2018-04-01","end-date": "2018-04-30",}
    end

    def get_report year_month 
      # logdate= "2018-04-05"
      set_period year_month

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
