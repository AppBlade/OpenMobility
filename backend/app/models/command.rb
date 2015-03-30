class Command < ActiveRecord::Base

  has_many :device_commands, dependent: :destroy
  has_many :devices, through: :device_commands

end
