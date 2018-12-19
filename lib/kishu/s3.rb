
require 'aws-sdk-s3'

require_relative 'utils'
require_relative 'base'

module Kishu
  class S3 

    def initialize
      s3 = Aws::S3::Client.new(
        :access_key_id => AWS_ACCESS_KEY_ID,
        :secret_access_key => AWS_SECRET_ACCESS_KEY
      )
      resp = s3.list_buckets
      resp.buckets.map(&:name)
    end

    def download_logs
      resp = s3.get_object(
        response_target: '/logs',
        bucket: S3_RESOLUTION_LOGS_BUCKET,
        key: 'object-key')
      resp.metadata
    end
  end
end