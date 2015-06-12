class Betas < ActiveRecord::Migration
  def change
    add_column :device_firmwares, :beta, :string
    remove_index :device_firmwares, :buildid
    add_index :device_firmwares, :buildid, unique: false
  end
end
