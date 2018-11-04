require 'spec_helper'


describe Kishu::Sushi, vcr: true, :order => :defined do

  describe "wrap_event" do
    context "when doi doesn't exist" do

      it "should fail" do
        response = subject.get_events
        # expect(response).to be({})
      end
    end
  #   context "when doi has not type assigned" do
  #     let(:event) {{
  #       "key": {
  #         "doi": "10.13130//3192"
  #       },
  #       "doc_count": 2,
  #       "totale": {
  #         "doc_count_error_upper_bound": 0,
  #         "sum_other_doc_count": 0,
  #         "buckets": [
  #           {
  #             "key": "10.13130//3192_regular",
  #             "doc_count": 2
  #           }
  #         ]
  #       },
  #       "unqiue": {
  #         "doc_count_error_upper_bound": 0,
  #         "sum_other_doc_count": 0,
  #         "buckets": [
  #           {
  #             "key": "2018-04-15_12_10.13130//3192_5.168.132.15_Mozilla/5.0 (Linux; Android 6.0.1; SAMSUNG SM-A520F Build/MMB29K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/5.4 Chrome/51.0.2704.106 Mobile Safari/537.36_regular",
  #             "doc_count": 1
  #           },
  #           {
  #             "key": "2018-04-15_16_10.13130//3192_151.15.225.227_Mozilla/5.0 (iPhone; CPU iPhone OS 11_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.0 Mobile/15E148 Safari/604.1_regular",
  #             "doc_count": 1
  #           }
  #         ]
  #       }
  #     }}
  #     it "should return an dataset event" do
  #       response = Event.wrap_event(event)
  #       expect(response).to eq({})
  #     end
  #   end
  #   context "when event is empty" do
  #     let(:event) {""}
  #     it "should fail" do
  #       response = Event.wrap_event(event)
  #       expect(response).to eq({})
  #     end
  #   end
  end


  describe "" do
    context "" do
      it "should return the data for one message" do
  
      end
    end
  end

  describe "" do
    context "" do
      it "" do
  
      end
    end
  end
end




