module Kishu
  module Utils

    


    def clean_tmp
      system("rm tmp/datasets-*.json")
      puts "/tmp Files deleted"
    end

  end
end
