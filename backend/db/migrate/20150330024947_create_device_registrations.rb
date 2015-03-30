class CreateDeviceRegistrations < ActiveRecord::Migration
  def change
    create_table :device_registrations do |t|
      t.string :enrollment_challenge_digest, null: false
      t.string :scep_challenge_digest
      t.string :state, null: false, default: 'challenged'
      t.string :user_agent
      t.text :challenge_certificate
      t.integer :device_id
      t.timestamps null: false
    end
  end
end
