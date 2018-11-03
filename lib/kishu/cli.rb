require 'thor'


require_relative 'sushi'


module Kishu
  class CLI < thor
    include Kishu::Base
    include Kishu::Utils
    include Kishu::Report
    include Kishu::Event

    # load ENV variables from .env file if it exists
    env_file = File.expand_path("../../.env", __FILE__)
    if File.exist?(env_file)
      require 'dotenv'
      Dotenv.overload env_file
    end

    def self.exit_on_failure?
      true
    end

    # from http://stackoverflow.com/questions/22809972/adding-a-version-option-to-a-ruby-thor-cli
    map %w[--version -v] => :__print_version

    desc "--version, -v", "print the version"
    def __print_version
      puts Kishu::VERSION
    end

    # desc "event SUBCOMMAND", "event commands"
    # subcommand "event", Kishu::Event

    desc "sushi SUBCOMMAND", "sushi commands"
    subcommand "sushi", Kishu::Sushi
  end
end
