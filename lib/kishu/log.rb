
require 'thor'

require_relative 'merger'
require_relative 'utils'
require_relative 'base'

module Kishu
  class Log < Thor

  include Kishu::Base
  include Kishu::Merger
  include Kishu::Utils


   desc "create logs", "create logs"
   method_option :logs_bucket,   :default => ENV['S3_RESOLUTION_LOGS_BUCKET']
   method_option :output_bucket, :default => ENV['S3_MERGED_LOGS_BUCKET']
   method_option :month_year,    :type => :string, :default => "201804"

   def create
      return "Logs don't exist" unless File.directory?(options[:month_year])
      return "Pipeline has events" unless Pipeline.new.is_empty?
      @log_date = get_date options[:month_year]
      @folder   = options[:month_year]  
      puts @log_date
      uncompress_files
      # add_bookends
      merge_files
      sort_files
   end
  end
end