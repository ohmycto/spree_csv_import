require 'fastercsv'
require 'state_machine'

namespace :spree_csv_import do

  desc 'Parse all csv files'
  task :parse_csv => :environment do
    path_to_csv = File.join(Rails.root, "public/csv_imports")
    path_to_complete_csv = File.join(path_to_csv, "completed")
    mkdir_p(path_to_complete_csv)

    taxonomy = Taxonomy.find_by_id(ARGV[1])
    taxonomy ||= Taxonomy.first

    files_to_parse = Dir.glob("#{path_to_csv}/*.csv")
    files_to_parse.each do |f|
      csv_parser = Parsers::CsvParser.new(:taxon => taxonomy.root)
      FasterCSV.foreach(f) do |line|
        csv_parser.parse(line)
      end
    end
  end
end