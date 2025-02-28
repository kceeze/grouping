require 'tty-prompt'
require 'csv'
require 'terminal-table'
require_relative "parse_csv.rb"

prompt = TTY::Prompt.new
matching_type = prompt.select("Which grouping would you like to bring back?", %w(EmailID PhoneID EmailAndPhoneID))

file = prompt.select("Which File would you like to bring back?", {
  "Input1.csv" => "input1_with_unique_ids.csv",
  "Input2.csv" => "input2_with_unique_ids.csv",
  "Input3.csv" => "input3_with_unique_ids.csv"
})

prompt_id = prompt.ask("What is the ID of the User?")

ParseCsv.return_people_from_csv(matching_type, file, prompt_id)
