require "bolognese"
require "time"

module Kishu
  module Utils
    include ::Bolognese::MetadataUtils
    
    def clean_tmp
      system("rm tmp/datasets-*.json")
      puts "/tmp Files deleted"
    end

    def merged_file
      "reports/datacite_resolution_report_#{report_period.strftime("%Y-%m")}_2.json"
    end

    def encoded_file
      "reports/datacite_resolution_report_#{report_period.strftime("%Y-%m")}_encoded.json"
    end 

    def generate_header_footer
      report_header = '{"report-header": '+get_header.to_json.to_s+',"report-datasets": [ '+"\n"
      
      File.open("tmp/datasets-00-report-header.json","w") do |f|
        f.write(report_header)
      end
      report_footer = ']'+"\n"+'}'
      
      File.open("tmp/datasets-zz99-report-footer.json","w") do |f|
        f.write(report_footer)
      end
    end

    def get_authors author
      if (author.key?("given") && author.key?("family"))
        { type: "name",
          value: author.fetch("given",nil)+" "+author.fetch("family",nil) }
        elsif author.key?("literal")
          { type: "name",
            value: author.fetch("literal",nil) }
        else 
          { type: "name",
            value: "" }
      end
    end

    def format_instance  data, options={}
      obj = get_metadata(options[:dataset_id])
      subj = {id:options[:report_id]}
      # subj = "https://api.datacite.org/reports/0cb326d1-e3e7-4cc1-9d86-7c5f3d5ca310"
      relation_type = "#{data[:"metric-type"]}-#{data[:"access-method"]}"
      source_id = "datacite-resolution"
      source_token = SOURCE_TOKEN
      { 
        "data" => {
          "type" => "events",
          "attributes" => {
            "message-action" => "create",
            "subj-id" => options[:report_id],
            "total" => data[:count],
            "obj-id" => options[:dataset_id],
            "relation-type-id" => relation_type.to_s.dasherize,
            "source-id" => source_id,
            "source-token" => source_token,
            "occurred-at" => Time.now.iso8601, # need modify
            "timestamp" => Time.now.iso8601,
            "license" => LICENSE,
            "subj" => subj,
            "obj" => obj } }}
    end

    def get_metadata id
      doi = doi_from_url(id)
      return {} unless doi.present?

      url = API_URL + "/dois/#{doi}"
      response = Maremma.get(url)
      return {} if response.status != 200
      
      attributes = response.body.dig("data", "attributes")
      relationships = response.body.dig("data", "relationships")
  
      resource_type = response.body.dig("data", "relationships")
      resource_type_general = relationships.dig("resource-type", "data", "id")
      type = Bolognese::Utils::CR_TO_SO_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.underscore.camelcase(first_letter = :upper)] || "CreativeWork"
      author = Array.wrap(attributes["author"]).map do |a| 
        {
          "given_name" => a["givenName"],
          "family_name" => a["familyName"],
          "name" => a["familyName"].present? ? nil : a["name"] }.compact
      end
      client_id = relationships.dig("client", "data", "id")
  
      {
        "id" => id,
        "type" => type.underscore.dasherize,
        "name" => attributes["title"],
        "author" => author,
        "publisher" => attributes["publisher"],
        "version" => attributes["version"],
        "date_published" => attributes["published"],
        "date_modified" => attributes["updated"],
        "registrant_id" => "datacite.#{client_id}" }.compact
    end

    def encoded
      Base64.strict_encode64(compress_merged_file)
    end

    def checksum
      Digest::SHA256.hexdigest(compress_merged_file)
    end

  end
end
