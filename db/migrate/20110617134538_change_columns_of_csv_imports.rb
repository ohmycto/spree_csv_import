class ChangeColumnsOfCsvImports < ActiveRecord::Migration
  def self.up
    rename_column :csv_product_imports, :products_count, :inserted_products_count

    change_table :csv_product_imports do |t|
      t.integer :updated_products_count
      t.integer :loaded_images_count
    end
  end

  def self.down
    rename_column :csv_product_imports, :inserted_products_count, :products_count

    change_table :csv_product_imports do |t|
      t.remove :updated_products_count
      t.remove :loaded_images_count
    end
  end
end
