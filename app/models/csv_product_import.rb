class CsvProductImport < ActiveRecord::Base
  belongs_to :taxonomy
  validates_length_of :filename, :maximum => 100
end
