require_relative 'resolution_event'


class LagottoJob
  include SuckerPunch::Job
  include Kishu::Utils
  workers 4 



  def perform(report, options={})
    # data = format_instance event, options

    # push_url = LAGOTTINO_URL  + "/events"
    # response =  Maremma.post(push_url, data: data.to_json,
    #               bearer: LAGOTTINO_TOKEN,
    #               content_type: 'application/vnd.api+json')
    # puts data
    # puts response.status
    Report.send_report report
  end
end