class AddIndexCodeToProducts < ActiveRecord::Migration
  def self.up
    add_index :products, :code, :unique => true
  end

  def self.down
    remove_index :products, :code
  end
end
