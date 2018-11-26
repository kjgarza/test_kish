require_relative 'resolution_event'


class LagottoJob
  include SuckerPunch::Job
  include Kishu::Utils
  workers 4 



  def perform(event, options={})
    data = format_instance event, options
    ENV['LAGOTTINO_URL'] = "https://api.test.datacite.org"

    push_url = ENV['LAGOTTINO_URL']  + "/events"
    response =  Maremma.post(push_url, data: data.to_json,
                  bearer: token,
                  content_type: 'application/vnd.api+json')
    puts data
    puts response.status
  end
end