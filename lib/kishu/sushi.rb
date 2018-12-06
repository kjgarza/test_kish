
require 'thor'


require_relative 'resolution_event'
require_relative 'report'
require_relative 'utils'
require_relative 'base'

module Kishu
  class Sushi < Thor

  include Kishu::Base
  include Kishu::Utils


   desc "get sushi", "get resolution report"
  #  method_option :username, :default => ENV['MDS_USERNAME']
   method_option :aggs_size, :type => :numeric, :default => 1000
   method_option :month_year, :type => :string, :default => "2018-04"
   def get
    x =Report.new()
    x.make_report(options)
    
   end

   method_option :month_year, :type => :string, :default => "2018-04"
   method_option :after_key, :type => :string
   def continue_report
    x =Report.new()
    x.generate_files(options)
    
   end

   desc "clean_all sushi", "clean index"
   method_option :month_year, :type => :string, :default => "2018-04"
   method_option :after_key, :type => :string
   def clean_all
    x =Client.new()
    x.clear_index
    
   end


   desc "send_report_events sushi", "send_report_events index"
   method_option :month_year, :type => :string, :default => "2018-04"
   method_option :after_key, :type => :string
   method_option :chunk_size, :type => :numeric, :default => 40000
   method_option :aggs_size, :type => :numeric, :default => 500
   def send_report_events
    fail "You need to set your JWT" if HUB_TOKEN.blank?
    x =Report.new(options)
    x.make_report(options)
    
   end

   
  end
end