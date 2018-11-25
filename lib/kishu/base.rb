require 'elasticsearch'
require 'json'
require 'faraday'



module Kishu
  module Base
    ES_HOST = 'localhost:9200'
    ENV['ES_HOST'] ||= 'localhost:9200'
    ENV['ES_INDEX'] ||= 'resolutions'
    ENV['LOGSTASH_HOST'] ||= 'localhost:9600'
    ENV['S3_RESOLUTION_LOGS_BUCKET'] ||= ""
    ENV['S3_MERGED_LOGS_BUCKET'] ||= ""
    # __elasticsearch__ = Faraday.new(url: ES_HOST)
    __elasticsearch__ = Elasticsearch::Client.new host: ES_HOST, transport_options: { request: { timeout: 3600, open_timeout: 3600 } }
  end
end
