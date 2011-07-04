class CreateAdyenSources < ActiveRecord::Migration
  def self.up
    create_table :adyen_sources do |t|
      t.string :psp_reference
      t.string :p_method      
      t.integer :payment_id
      t.timestamps
    end
  end

  def self.down
    drop_table :adyen_sources
  end
end
