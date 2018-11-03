require 'elasticsearch'
require 'json'
require 'faraday'



module Kishu
  module Base
    ES_HOST = 'localhost:9200'
    # __elasticsearch__ = Faraday.new(url: ES_HOST)
    __elasticsearch__ = Elasticsearch::Client.new host: ES_HOST, transport_options: { request: { timeout: 3600, open_timeout: 3600 } }
  end
end
