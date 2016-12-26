class ApplicationController < ActionController::Base
  include ShopifyApp::LoginProtection
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session
  def _prepare_option(product, option_data)
  # todo performance

	  if option_data['preview_type'] == 'Img'
	    preview_img = product.images.find { |i| i.id == option_data['preview_data']['value'] }
	    if preview_img
	      option_data['preview_data']['value'] = preview_img.attributes[:src]
	    end
	  end

	  if option_data['option_type'] == 'Img'
	    preview_img = product.images.find { |i| i.id == option_data['option_data']['value'] }
	    if preview_img
	      option_data['option_data']['value'] = preview_img.attributes[:src]
	    end
	  end

	  return option_data
	end
end
