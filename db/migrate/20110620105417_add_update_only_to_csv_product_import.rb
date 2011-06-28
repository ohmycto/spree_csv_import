class AddUpdateOnlyToCsvProductImport < ActiveRecord::Migration
  def self.up
    add_column :csv_product_imports, :update_only, :boolean, :default => false
  end

  def self.down
    remove_column :csv_product_imports, :update_only
  end
end
