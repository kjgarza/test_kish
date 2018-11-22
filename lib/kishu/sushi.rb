
require 'thor'


require_relative 'event'
require_relative 'report'
require_relative 'utils'
require_relative 'base'

module Kishu
  class Sushi < Thor

  include Kishu::Base
  include Kishu::Report
  include Kishu::Utils
  include Kishu::Event

   desc "get sushi", "get resolution report"
  #  method_option :username, :default => ENV['MDS_USERNAME']
   method_option :aggs_size, :type => :numeric, :default => 1000
   method_option :month_year, :type => :string, :default => "2018-04"

   def get
    Report.new(options).get_report
    # get_report options






    #  if doi == "all"
    #    response = get_dois(options)
    #  else
    #    response = get_doi(doi, options)
    #  end

    #  if response.body["errors"]
    #    puts "Error: " + response.body["errors"].first.fetch("title", "An error occured")
    #  elsif doi == "all"
    #    puts response.body["data"][0...options[:limit]]
    #  else
    #    puts response.body["data"]
    #  end
   end
  end
end