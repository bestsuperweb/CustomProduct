# proxy
@data = File.read("#{Rails.root}/app/assets/javascripts/custom-product-builder.js")

class ProxyController < ShopifyApp::AuthenticatedController

  def index
    puts "PROXY REQUEST"
    puts params
  end

  def client

    # data = File.read("../assets/javascripts/custom-product-builder.js")
    # render :js => data
    # render :body => '../assets/javascripts/custom-product-builder.js', content_type: "text/javascript"
    # render :body => '../assets/javascripts/custom-product-builder.js', content_type: "text/javascript"

    js_data = [
        '(function(){console.log(11111}()'
        # 'asdasd'
    ].join('')

    render :js => js_data, content_type: "text/javascript"
  end
end