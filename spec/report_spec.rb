require 'spec_helper'


describe Kishu::Report, vcr: true, :order => :defined do
  let(:report) {Kishu::Report.new()}
  describe "report_period" do
    context "when doi doesn't exist" do

      it "should fail" do
        response = subject.get_events
        # expect(response).to be({})
      end
    end
  end


  describe "get_events" do
    context "" do
      it "should return the data for one message" do
  
      end
    end
  end

  describe "generate_dataset_array" do
    context "" do
      it "" do
  
      end
    end
  end

  describe "compress" do
    context "when json arrives compresses it correctly" do
      
      it "compresses" do
        
      end
    end
  end


  describe "generate_chunk_report" do
    context "" do
      it "" do
  
      end
    end
  end

  describe "set_period" do
    context "" do
      it "" do
  
      end
    end
  end

  describe "send_report" do
    context "when the report is good" do
      it "" do
  
      end
    end

    context "when the report is bad" do
      let(:report) {}
      it "return error" do
        status = Report.send_report report
        expect(status).not_to eq("201")
      end
    end
  end

end




