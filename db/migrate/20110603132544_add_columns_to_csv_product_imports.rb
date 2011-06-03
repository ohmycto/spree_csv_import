class AddColumnsToCsvProductImports < ActiveRecord::Migration
  def self.up
    change_table :csv_product_imports do |t|
      t.references :taxonomy
      t.datetime :parsed_date, :default => nil
    end
  end

  def self.down
    remove_columns :csv_product_imports, :taxonomy_id, :parsed_date
  end
end
