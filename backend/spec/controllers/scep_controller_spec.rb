require 'rails_helper'

RSpec.describe ScepController, type: :controller do

  subject { build_stubbed(:device_registration_scep_exchange) }

  it 'should respond to GetCACert' do

    response = get :operation, {id: subject.id, operation: 'GetCACert'}

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eql 'application/x-x509-ca-cert'
    cert = OpenSSL::X509::Certificate.new response.body
    expect(cert.to_pem).to eql ScepCert.to_pem

  end

  it 'should respond to GetCACaps' do

    response = get :operation, {id: subject.id, operation: 'GetCACaps'}

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eql 'text/plain'
    expect(response.body).to eql "POSTPKIOperation\nSHA-1"


  end

end
