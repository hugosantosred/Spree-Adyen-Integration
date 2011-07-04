Rails.application.routes.draw do
  # Add your extension routes here
  match '/adyen_notify' => 'adyen_callback#index', :via => [:get, :post]
end
