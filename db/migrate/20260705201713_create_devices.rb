class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :tuya_device_id
      t.string :ip
      t.string :local_key
      t.string :protocol_version
      t.string :category
      t.boolean :on_off
      t.boolean :brightness
      t.boolean :color

      t.timestamps
    end
  end
end
