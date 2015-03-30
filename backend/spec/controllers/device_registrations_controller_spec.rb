require 'rails_helper'

RSpec.describe DeviceRegistrationsController, type: :controller do

  # create should generate a new device registration and return a JSON response
  # following the mobileconfig link from the JSON response should do the expected thing
     # have a challenge & enrollment path
  # should handle a signed iPhone payload
  
  context "should have the expected challenge workflow" do

    let(:initial_create) { post :create, {}, {'HTTP_ACCEPT' => 'application/xml'} }
    let(:device_registration_request) { get :show, id: 1 }
    let(:device_registration_update) { post :update, id: 1 }

    it 'handles the initial registration request' do
      expect(initial_create).to be(:success?)
      expect(initial_create.body).to eql("")
    end

  end

end
