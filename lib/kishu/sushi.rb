
require 'thor'


require_relative 'resolution_event'
require_relative 'report'
require_relative 'utils'
require_relative 'base'

module Kishu
  class Sushi < Thor

  include Kishu::Base
  include Kishu::Utils


   desc "clean_all sushi", "clean index"
   method_option :month_year, :type => :string, :default => "2018-04"
   method_option :after_key, :type => :string
   def clean_all
    x =Client.new()
    x.clear_index
    
   end

   desc "stream a sushi", "stream report"
   method_option :month_year,  :type => :string, :default => "2018-04"
   method_option :after_key,   :type => :string
   method_option :report_size, :type => :numeric, :default => 40000
   method_option :aggs_size,   :type => :numeric, :default => 500
   method_option :schema,      :type => :string, :default => "usage"
   method_option :enrich,      :type => :boolean, :default => false
   method_option :encoding,     :type => :string, :default => "gzip"
   method_option :created_by,  :type => :string, :default => "datacite"
   def stream
    fail "You need to set your JWT" if HUB_TOKEN.blank?
    report = Report.new(options)
    report.generate_dataset_array
    LOGGER.info  "#{LOGS_TAG} Month of #{report.period.dig("begin-date")} sent to Hub in report #{report.uid} with stats for #{report.total} datasets"
   end

   desc "generate a sushi", "generate report"
   method_option :schema,      :type => :string, :default => "usage"
   method_option :enrich,      :type => :boolean, :default => true
   method_option :encoding,     :type => :string, :default => "json"
   method_option :created_by,  :type => :string, :default => "datacite"
   def generate
    report = Report.new(options)
    report.generate
    file = report.merged_file
    File.open(file,"w") do |f|
      f.write(JSON.pretty_generate report.get_template)
    end
    LOGGER.info  "#{LOGS_TAG} Month of #{report.period.dig("begin-date")} with stats for #{report.total} datasets"
   end

   desc "push a sushi", "push report"
   method_option :schema,      :type => :string, :default => "usage"
   method_option :enrich,      :type => :boolean, :default => true
   method_option :encoding,     :type => :string, :default => "json"
   method_option :created_by,  :type => :string, :default => "datacite"
   def push
    fail "You need to set your JWT" if HUB_TOKEN.blank?
    report = Report.new(options)
    report.generate
    report.send_report report.get_template
    LOGGER.info  "#{LOGS_TAG} Month of #{report.period.dig("begin-date")} sent to Hub in report #{report.uid} with stats for #{report.total} datasets"
   end

   desc "is ES running", "check es is working" 
   def elasticsearch_results
    es = Client.new()
    es = es.get({aggs_size: 10, after_key: ""})
    puts es.dig("hits","total")
    puts "Aggregations:" + es.fetch("aggregations",[]).first.to_s
   end

  end
end