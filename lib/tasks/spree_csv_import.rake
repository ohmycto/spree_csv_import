require 'fastercsv'
require 'state_machine'

namespace :spree_csv_import do

  desc 'Parse all files'
  task :parse_csv => :environment do
    files_to_parse = Dir.glob(File.join(Rails.root, "public/csv_imports/*.csv"))
    files_to_parse.each do |f|
      parse_csv_file(f)
    end
  end
end

def parse_csv_file(file)
  csv_parser = Parsers::CsvParser.new(:taxon => Taxon.first)

  FasterCSV.foreach(file) do |line|
    csv_parser.parse(line)
  end

  puts csv_parser.taxons.map(&:name)
end