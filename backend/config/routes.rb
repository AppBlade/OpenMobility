Rails.application.routes.draw do

  resources :device_registrations, only: :create do
    post :update, on: :member
    match 'certificates' => 'scep#operation', on: :member, via: [:get, :post], as: :scep
  end

end
