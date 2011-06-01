class AddCodeToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :code, :string, :limit => 20
  end

  def self.down
    remove_column :products, :code
  end
end
