class AddColumnsToCsvProductsImport < ActiveRecord::Migration
  def self.up
    change_table :csv_product_imports do |t|
      t.string :status
    end
  end

  def self.down
    remove_columns :csv_product_imports, :status
  end
end
