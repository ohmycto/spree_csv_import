class CsvProductImport < ActiveRecord::Base
  validates_length_of :file, :maximum => 100
end
