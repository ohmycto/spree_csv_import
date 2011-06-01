class CreateCsvProductImports < ActiveRecord::Migration
  def self.up
    create_table :csv_product_imports do |t|
      t.string :file, :limit => 100
      t.integer :product_counts
    end
  end

  def self.down
    drop_table :csv_product_imports
  end
end
