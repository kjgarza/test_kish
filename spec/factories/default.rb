
FactoryBot.define do
  factory :resolution_event do
    period  "begin_date": "2018-03-01", "end_date": "2018-03-31"
    event  
    {
      "key": "10.5065/D6V1236Q",
      "doc_count": 5566,
      "total": {
        "doc_count_error_upper_bound": 0,
        "sum_other_doc_count": 0,
        "buckets": [
          {
            "key": "machine",
            "doc_count": 5093
          },
          {
            "key": "regular",
            "doc_count": 473
          }
        ]
      },
      "access_method": {
        "doc_count_error_upper_bound": 0,
        "sum_other_doc_count": 0,
        "buckets": [
          {
            "key": "machine",
            "doc_count": 5093,
            "session": {
              "doc_count_error_upper_bound": 10,
              "sum_other_doc_count": 5072,
              "buckets": [
                {
                  "key": "2018-09-18_16_10.5065/D6V1236Q_54.71.12.185_curl/7.38.0",
                  "doc_count": 5
                },
                {
                  "key": "2018-09-01_05_10.5065/D6V1236Q_45.79.139.170_curl/7.38.0",
                  "doc_count": 4
                },
                {
                  "key": "2018-09-03_16_10.5065/D6V1236Q_52.40.104.81_curl/7.38.0",
                  "doc_count": 4
                },
                {
                  "key": "2018-09-12_00_10.5065/D6V1236Q_52.39.7.168_curl/7.38.0",
                  "doc_count": 4
                },
                {
                  "key": "2018-09-26_06_10.5065/D6V1236Q_52.39.7.168_curl/7.38.0",
                  "doc_count": 4
                }
              ]
            },
            "unqiue": {
              "value": 3084
            }
          }]  
      }
    }
  end


  factory :usage_event do
  end

  factory :report do
  end

end
