require 'spec_helper'


describe Kishu::Report, vcr: true, :order => :defined do
  let(:report) {Kishu::Report.new()}
 
  describe "compress" do
    context "when json arrives compresses it correctly" do
      
      it "compresses" do
        
      end
    end
  end

  describe "get_template" do
    context "when Godd Usage report" do
      let(:usage_params) {{encoding:"json",schema:"usage",enrich:true,created_by:"DataOne"}}
      let(:datasets) {fixture_file("usage_datasest_array.json")}
      let(:period) {{}}
      it "generate a good template" do
        response = Report.new(usage_params)
        response.datasets = datasets
        expect(response.get_template.dig("report-header","release")).to eq("rd1")
        expect(response.get_template.dig("report-header","created_by")).to eq("DataOne")
        expect(response.get_template.dig("report-datasets").size).to eq(10)
      end
    end

    context "when Godd Resolution report" do
      let(:resolution_params) {{encoding:"json",schema:"resolution",enrich:false,created_by:"Dash"}}
      let(:datasets) {fixture_file("usage_datasest_array.json")}
      let(:period) {{}}
      it "generate a good template" do
        response = Report.new(resolution_params)
        response.datasets = datasets
        expect(response.get_template.dig("report-header","release")).to eq("dlr")
        expect(response.get_template.dig("report-header","created_by")).to eq("Dash")
        expect(response.get_template.dig("report-datasets").size).to eq(10)
      end
    end
    context "when Bad Resolution report" do
      let(:resolution_params) {{encoding:"json",schema:"resolution",enrich:false,created_by:"Dash"}}
      let(:datasets) {fixture_file("usage_datasest_array.json")}
      let(:period) {{}}
      it "generate a good template" do
        response = Report.new(resolution_params)
        response.datasets = datasets
        expect(response.get_template.dig("report-header","release")).to eq("dlr")
        expect(response.get_template.dig("report-header","created_by")).to eq("Dash")
        expect(response.get_template.dig("report-datasets").size).to eq(10)
      end
    end
  end

  describe "send_report" do
    context "when Godd Usage report" do
      let(:usage_params) {{encoding:"json",schema:"usage",enrich:true,created_by:"DataOne"}}
      let(:datasets) {fixture_file("usage_datasest_array.json")}
      let(:period) {{}}
      it "return 200" do
        report = Report.new(usage_params)
        report.datasets = datasets
        response = report.send_report
        expect(response.status).to eq(201)  
      end
    end
    context "when Godd Resolution report" do
      let(:resolution_params) {{encoding:"json",schema:"resolution",enrich:false,created_by:"datacite"}}
      let(:datasets) {fixture_file("usage_datasest_array.json")}
      let(:period) {{}}
      it "return 200" do
        report = Report.new(resolution_params)
        report.datasets = datasets
        response = report.send_report
        expect(response.status).to eq(201)  
      end
    end

    context "when the report is bad" do
      let(:report) {}
      it "return error" do
        # status = Report.send_report report
        # expect(status).not_to eq("201")
      end
    end
  end

end




