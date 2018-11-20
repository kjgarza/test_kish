
require 'date'

module Kishu
  module Merger

    FILE_STEM = "DataCite-access.log"

    def get_date filename
      Date.parse("#{filename}01")
    end

    # def merge_logs 
    #   @log_date = get_date ARGV[0]
    #   @folder = ARGV[0]
    #   puts @log_date
    #   uncompress_files
    #   add_bookends
    #   merge_files
    #   sort_files
    # end

    def uncompress_files
      system("gunzip #{resolution_logs_folder}/#{FILE_STEM}-*")
    end


    def add_bookends
      File.delete("#{resolution_logs_folder}/#{FILE_STEM}-1-begin.log") if File.exist?("#{resolution_logs_folder}/#{FILE_STEM}-1-begin.log")
      File.delete("#{resolution_logs_folder}/#{FILE_STEM}-9-eof.log") if File.exist?("#{resolution_logs_folder}/#{FILE_STEM}-9-eof.log")

      begin_date = Date.civil(@log_date.year,@log_date.month,1).strftime("%Y-%m-%d")
      end_date   = Date.civil(@log_date.year,@log_date.month+1, 1).strftime("%Y-%m-%d") 

      begin_line = '0.0.0.0 HTTP:HDL "'+begin_date+' 00:00:00.000Z" 1 1 22ms 10.5281/zenodo.1043571 "300:10.admin/codata" "" "Mozilla"'+"\n"
      puts begin_line

      end_line = '0.0.0.0 HTTP:HDL "'+end_date+' 00:01:00.000Z" 1 1 22ms 10.5281/zenodo.1043571 "300:10.admin/codata" "" "Mozilla"'+"\n"
      puts end_line

      File.open("#{resolution_logs_folder}/#{FILE_STEM}-1-begin.log","w") {|f| f.write(begin_line) }
      File.open("#{resolution_logs_folder}/#{FILE_STEM}-9-eof.log","w") {|f| f.write(end_line) }
    end

    def merged_file
      "#{merged_logs_folder}/datacite_resolution_logs_#{@log_date}.log"
    end

    def sorted_file
      "#{resolution_logs_folder}/datacite_resolution_logs_#{@log_date}_sorted.log"
    end

    def resolution_logs_folder
      bucket = if ENV['S3_RESOLUTION_LOGS_BUCKET'] ? ENV['S3_RESOLUTION_LOGS_BUCKET'] : "./"
      end
      "#{bucket}#{@folder}"
    end

    def merged_logs_folder
      bucket = if ENV['S3_MERGED_LOGS_BUCKET'] ? ENV['S3_MERGED_LOGS_BUCKET'] : "./monthly_logs"
      end
      "#{bucket}#{@folder}"
    end

    def merge_files
      File.delete(merged_file) if File.exist?(merged_file)

      system("cat #{resolution_logs_folder}/#{FILE_STEM}-* > #{merged_file}")
      puts "Merged Completed"
    end

    def sort_files
      File.delete(sorted_file) if File.exist?(sorted_file)

      system("sort -k3 #{merged_file} > #{sorted_file}")
      puts "Sorted Completed"
      puts sorted_file
    end
  end
end