require 'fastercsv'
require 'state_machine'

namespace :spree_csv_import do

  desc 'Parse all csv files'
  task :parse_csv => :environment do
    path_to_csv = File.join(Rails.root, "tmp")
    if ENV['task_id'].present?
      csv_task_id = ENV['task_id']
      csv_task = CsvProductImport.find_by_id(csv_task_id)

      if csv_task
        filename = csv_task.filename
        taxon = csv_task.taxon
        csv_file = File.join(path_to_csv, filename)
      end
    elsif ENV['input_file'].present?
      filename = ENV['input_file']
      taxon = Taxon.find_by_id(ENV['taxon'])
      taxon ||= Taxonomy.first.root
      csv_file = File.join(path_to_csv, filename)
    end
    allow_insert = ENV['update_only'].nil?

    if csv_file.present? && File.exist?(csv_file)
      if taxon

        begin
          csv_parser = Parsers::CsvParser.new({:taxon => taxon, :allow_insert => allow_insert})
          FasterCSV.foreach(csv_file) do |line|
            csv_parser.parse(line)
          end

          if csv_task.present?
            csv_task.parsed_date = DateTime.now
            csv_task.status = 'completed'
            csv_task.inserted_products_count = csv_parser.inserted_products.count
            csv_task.updated_products_count = csv_parser.updated_products.count
            csv_task.loaded_images_count = csv_parser.loaded_images_count
            csv_task.save
          end
        rescue
          set_error_status_for_csv_task csv_task
        end
      else
        set_error_status_for_csv_task csv_task
        puts "There is no taxonomy"
      end
    else
      if csv_file.nil?
        puts "Filename not presented"
      else
        puts "File #{csv_file} doesn't exist"
      end
      set_error_status_for_csv_task csv_task
    end
  end
end

def set_error_status_for_csv_task(task)
  if task.present?
    task.parsed_date = DateTime.now
    task.status = 'error'
    task.save
  end
end