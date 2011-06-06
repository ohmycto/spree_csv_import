class CreateCsvProductImports < ActiveRecord::Migration
  def self.up
    create_table :csv_product_imports do |t|
      t.string :filename, :limit => 100
      t.integer :products_count
      t.references :taxonomy
      t.datetime :parsed_date, :default => nil

      t.timestamps
    end
  end

  def self.down
    drop_table :csv_product_imports
  end
end
