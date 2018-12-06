require "kishu/resolution_event"
require "kishu/usage_event"
require "kishu/report"
require "kishu/cli"
require "kishu/sushi"
require "kishu/version"
require "kishu/client"
require "kishu/log"
require "kishu/pipeline"
require "kishu/lagotto_job"


API_URL         = ENV['API_URL'] ? ENV['API_URL'] : "https://api.datacite.org"
HUB_URL         = ENV['HUB_URL'] ? ENV['HUB_URL'] : "https://api.test.datacite.org"
HUB_TOKEN       = ENV['HUB_TOKEN'] ? ENV['HUB_TOKEN'] : ""
ES_HOST         = ENV['ES_HOST'] ? ENV['ES_HOST'] : "localhost:9200"
ES_INDEX        = ENV['ES_INDEX'] ? ENV['ES_INDEX'] : "resolutions"
LOGSTASH_HOST   = ENV['LOGSTASH_HOST'] ? ENV['LOGSTASH_HOST'] : "localhost:9600"
LAGOTTINO_URL   = ENV['LAGOTTINO_URL'] ? ENV['LAGOTTINO_URL'] : "https://api.test.datacite.org"
LAGOTTINO_TOKEN = ENV['LAGOTTINO_TOKEN'] ? ENV['LAGOTTINO_TOKEN'] : ""
LICENSE         = ENV['LICENSE'] ? ENV['LICENSE'] : "https://creativecommons.org/publicdomain/zero/1.0/"
SOURCE_TOKEN    = ENV['SOURCE_TOKEN'] ? ENV['SOURCE_TOKEN'] : "65903a54-01c8-4a3f-9bf2-04ecc658247a"
S3_MERGED_LOGS_BUCKET     = ENV['S3_MERGED_LOGS_BUCKET'] ? ENV['S3_MERGED_LOGS_BUCKET'] : "./monthly_logs"
S3_RESOLUTION_LOGS_BUCKET = ENV['S3_RESOLUTION_LOGS_BUCKET'] ? ENV['S3_RESOLUTION_LOGS_BUCKET'] : "./"
AWS_REGION                = ENV['AWS_REGION'] ? ENV['AWS_REGION'] : ""
AWS_ACCESS_KEY_ID         = ENV['AWS_ACCESS_KEY_ID'] ? ENV['AWS_ACCESS_KEY_ID'] : ""
AWS_SECRET_ACCESS_KEY     = ENV['AWS_SECRET_ACCESS_KEY'] ? ENV['AWS_SECRET_ACCESS_KEY'] : ""
ELASTIC_PASSWORD          = ENV['ELASTIC_PASSWORD'] ? ENV['ELASTIC_PASSWORD'] : ""
LOGS_TAG  = "[Resolution Logs]"
puts ENV.to_a