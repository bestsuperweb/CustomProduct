Rails.application.routes.draw do
  mount ShopifyApp::Engine, at: '/'
  root :to => 'admin#index'

  get 'proxy' => 'proxy#index'
  post 'proxy' => 'proxy#index'
  put 'proxy' => 'proxy#index'
  delete 'proxy' => 'proxy#index'

  get 'client/client.js' => 'proxy#client'

  get 'customizer' => 'admin#customizer'

  get 'api/product/:product_id' => 'api_admin#get_product'

  put 'api/product/:product_id/preview' => 'api_admin#update_product_preview'
  delete 'api/product/:product_id/preview' => 'api_admin#delete_product_preview'

  get 'api/product/:product_id/panels' => 'api_admin#get_panels'
  post 'api/product/:product_id/panels' => 'api_admin#add_panel'
  put 'api/product/:product_id/panels/:panel_id' => 'api_admin#update_panel'
  delete 'api/product/:product_id/panels/:panel_id' => 'api_admin#delete_panel'

  get 'api/product/:product_id/categories' => 'api_admin#get_categories'
  post 'api/product/:product_id/categories' => 'api_admin#add_category'
  put 'api/product/:product_id/categories/:category_id' => 'api_admin#update_category'
  delete 'api/product/:product_id/categories/:category_id' => 'api_admin#delete_category'

  get 'api/product/:product_id/options' => 'api_admin#get_options'
  post 'api/product/:product_id/options' => 'api_admin#add_option'
  put 'api/product/:product_id/options/:option_id' => 'api_admin#update_option'
  delete 'api/product/:product_id/options/:option_id' => 'api_admin#delete_option'

end
