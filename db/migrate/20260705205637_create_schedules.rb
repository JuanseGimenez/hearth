class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :device, null: false, foreign_key: true
      t.string :action
      t.json :params
      t.integer :hour
      t.integer :minute
      t.string :days_of_week
      t.boolean :enabled

      t.timestamps
    end
  end
end
