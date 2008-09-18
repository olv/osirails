class CreateOrdersSteps < ActiveRecord::Migration
  def self.up
    create_table :orders_steps do |t|
      t.references :order
      t.references :step
      t.string :status
      t.datetime :start_date
      t.datetime :end_date
    end
  end

  def self.down
    drop_table :orders_steps
  end
end