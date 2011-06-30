class CsvProductImport < ActiveRecord::Base
  belongs_to :taxon
  validates_length_of :filename, :maximum => 100
end
