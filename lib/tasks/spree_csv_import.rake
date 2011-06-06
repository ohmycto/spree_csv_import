require 'fastercsv'
require 'state_machine'

namespace :spree_csv_import do

  desc 'Parse all csv files'
  task :parse_csv => :environment do
    path_to_csv = File.join(Rails.root, "tmp")
    if ARGV.length == 2
      csv_task_id = ARGV[1]
      csv_task = CsvProductImport.find_by_id(csv_task_id)

      if csv_task
        filename = csv_task.filename
        taxonomy = csv_task.taxonomy
        csv_file = File.join(path_to_csv, filename)
      end
    else
      filename = ARGV[2]
      taxonomy = Taxonomy.find_by_id(ARGV[1])
      taxonomy ||= Taxonomy.first
      csv_file = File.join(path_to_csv, filename)
    end

    if File.exist?(csv_file) && taxonomy
      csv_parser = Parsers::CsvParser.new(:taxon => taxonomy.root)
      FasterCSV.foreach(csv_file) do |line|
        csv_parser.parse(line)
      end

      if csv_task.present?
        csv_task.parsed_date = DateTime.now
        csv_task.products_count = csv_parser.products.count
        csv_task.save
      else
        puts "--- There is no task"
      end
    end
  end
end