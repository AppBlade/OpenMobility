Rails.application.routes.draw do

  resources :device_registrations, only: :create do
    post :update, on: :member
    match 'certificates' => 'scep#operation', on: :member, via: [:get, :post], as: :scep
    match '' => 'mdm#check_in',   on: :member, via: :put
    match 'queue' => 'mdm#queue', on: :member, via: :put
  end

end
