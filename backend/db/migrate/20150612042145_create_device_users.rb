class CreateDeviceUsers < ActiveRecord::Migration
  def change
    create_table :device_users do |t|
      t.string :user_id, :user_long_name, :user_short_name
      t.integer :device_id, null: false
      t.timestamps null: false
    end
    add_index :device_users, :device_id
    add_index :device_users, [:device_id, :user_id], unique: true

    create_table :device_user_registrations do |t|
      t.string :apns_token, :apns_push_magic
      t.integer :device_user_id, :device_registration_id, null: false
    end
    add_index :device_user_registrations, :device_user_id
    add_index :device_user_registrations, :device_registration_id
    add_index :device_user_registrations, [
      :device_user_id,
      :device_registration_id
    ], name: 'uniqueness', unique: true

    add_column :device_commands, :device_user_id, :integer

  end
end
