class CreateCommands < ActiveRecord::Migration
  def change

    create_table :commands do |t|
      t.string :type
      t.text :settings
      t.integer :dependent_command_id
      t.timestamps null: false
    end
    add_index :commands, [:id, :type], name: :notnow_queue

    create_table :device_commands do |t|
      t.integer :device_id, :command_id, null: false
      t.integer :device_registration_id
      t.string :state, null: false, default: 'pending'
      t.datetime :received_at
    end
    add_index :device_commands, [:id, :device_id], name: :log_status
    add_index :device_commands, [:device_id, :state], name: :queue

  end
end
