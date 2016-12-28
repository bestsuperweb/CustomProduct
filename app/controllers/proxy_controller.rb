# proxy
@data = File.read("#{Rails.root}/app/assets/javascripts/custom-product-builder.js")

class AppProxy::ProxyController < ApplicationController
include ShopifyApp::AppProxyVerification
  def index
    puts "PROXY REQUEST"
    puts params
  end

  def client
    # tmp_shop = Shop.where(shopify_domain: params[:shop]).first
    # shop_sess = ShopifyAPI::Session.new(params[:shop], tmp_shop.shopify_token)
    # ShopifyAPI::Base.activate_session(shop_sess)
    # session[:session_shopify] = shop_sess
    @id = params[:product_id]
    puts ">>>>>>> customizer"
    product = ShopifyAPI::Product.find(@id.to_i)
    product_id = product.id

    panels = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_panels", :order => "created_at ASC"})
    categories = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_cat", :order => "created_at ASC"})
    options = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_opt", :order => "created_at ASC"})

    render_product_preview = []
    render_panels = []
    render_categories = []
    render_options = []

    for panel in panels
      panel_data = JSON.parse(panel.value)
      render_panels.push({id: panel.id}.merge(panel_data))
    end

    for category in categories
      category_data = JSON.parse(category.value)
      render_categories.push({id: category.id}.merge(category_data))
    end

    for option in options
      option_data = JSON.parse(option.value)
      render_options.push({id: option.id}.merge(_prepare_option(product, option_data)))
    end

    for img in product.images
      if img.position == 1
        render_product_preview = [
            {
                preview_type: 'Img',
                option_type: '',
                preview_data: {
                    value: img.attributes[:src]
                },
                option_data: {}
            }
        ]
        break
      end
    end

    @customizer_config = {
        isAdmin: false,
        cdnPath: Rails.application.config.assets.cdn_path,
        apiPrefix: Rails.application.config.assets.api_prefix,
        apiAuthentication: {
            tokenName: request_forgery_protection_token.to_s,
            tokenValue: form_authenticity_token
        },
        settings: {
            layout: "horizontal",
            type: "accordion",
            theme: "vento-grey"
        }
    }.to_json

    @customizer_data = {
        product: {
            id: product_id,
            preview: render_product_preview
        },
        panels: render_panels,
        categories: render_categories,
        options: render_options
    }.to_json
  end
end