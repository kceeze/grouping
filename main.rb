require 'msg-batcher'
require_relative "parse_csv.rb"
require_relative "person.rb"
require 'phony'
require "csv"
require "byebug"
require "active_support"
require_relative "underscore.rb"

require "active_support"
csv_files = Dir.glob("*.csv")
csv_files.sort.each do | csv_file|
    # Parse the CSV Files in this directory and populate people from the person class
    ParseCsv.parse_csv_file(csv_file, true)
end