class CreateGraphicConceptionSteps < ActiveRecord::Migration
  def self.up
    create_table :graphic_conception_steps do |t|
      t.references :commercial_step
      t.string    :status
      t.datetime  :started_at, :finished_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :graphic_conception_steps
  end
end
