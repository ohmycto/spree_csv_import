class CsvProductImport < ActiveRecord::Base
  validates_length_of :filename, :maximum => 100
end
