ShopifyApp.configure do |config|
  config.api_key = "bbc3c810cfdda91d94c5d5e60d74153a"
  config.secret = "a0cf8803c66b8a0fba4b46d4baf8c0a0"
  config.scope = "read_orders, write_products, read_products, read_themes, write_themes"
  config.embedded_app = true
  config.pos_app = true
end
