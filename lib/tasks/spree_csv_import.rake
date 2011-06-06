require 'fastercsv'
require 'state_machine'

namespace :spree_csv_import do

  desc 'Parse all csv files'
  task :parse_csv => :environment do
    path_to_csv = File.join(Rails.root, "tmp")

    filename = ARGV[2]
    taxonomy = Taxonomy.find_by_id(ARGV[1])
    taxonomy ||= Taxonomy.first

    csv_file = File.join(path_to_csv, filename)

    if File.exist?(csv_file)
      csv_parser = Parsers::CsvParser.new(:taxon => taxonomy.root)
      FasterCSV.foreach(csv_file) do |line|
        csv_parser.parse(line)
      end
    end
  end
end