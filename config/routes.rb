Rails.application.routes.draw do
  namespace :admin do
    resources :csv_product_imports
  end
end
