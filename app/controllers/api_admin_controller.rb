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

def _del_image(product, img_id)
  for img in product.images
    if img.id == img_id
      product.images = product.images - [img]
      img.destroy
      product.save
      break
    end
  end
end

def _save_img(product, base64, params={})

  if !base64 or !base64.chars.length
    return false
  end

  base64 = base64.gsub(/(data\:image\/)[^;]+;base64,/, '')

  image = ShopifyAPI::Image.new({:product_id => product.id}.merge(params))
  image.attachment = base64
  image.save

  product.images.push(image)
  product.save

  return image
end


def _del_panel(product_id, panel_id)

  panel = ShopifyAPI::Metafield.find(panel_id)
  panel.destroy

  categories = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_cat"})
  delete_categories = []

  for category in categories
    category_data = JSON.parse(category.value)
    if category_data['panel_id'] == panel_id
      delete_categories.push(category.id)
    end
  end

  for category_id in delete_categories
    _del_category(product_id, category_id)
  end

end

def _del_category(product_id, category_id)

  category = ShopifyAPI::Metafield.find(category_id)
  category.destroy

  options = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_opt"})
  delete_options = []

  for option in options
    option_data = JSON.parse(option.value)
    if option_data['category_id'] == category_id
      delete_options.push(option.id)
    end
  end

  for option_id in delete_options
    _del_option(product_id, option_id)
  end

end

def _del_option(product_id, option_id)

  option = ShopifyAPI::Metafield.find(option_id)
  option.destroy
#   DELETE IMAGES HERE

end

def _save_option_images(product, option, prev_option)

  if prev_option

    if prev_option['preview_type'] == 'Img'

      if prev_option['preview_data']['value'] and option[:preview_type] != 'Img' or prev_option['preview_data']['value'] != option[:preview_data]['value']
        # delete old image
        _del_image(product, prev_option['preview_data']['value'])
      end

      if option[:preview_type] == 'Img' and option[:preview_data]['value'] and option[:preview_data]['value'] !=prev_option['preview_data']['value']
        update_img = _save_img(product, option[:preview_data]['value'])
        if update_img
          option[:preview_data]['value'] = update_img.id
        end
      end

    end

  else

  end

  return option
end

class ApiAdminController < ShopifyApp::AuthenticatedController

  def get_product

    product = ShopifyAPI::Product.find(params[:product_id])
    product_id = product.id
    render_product_preview = []

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

    render json: {
        status: 200,
        data: {
            id: product_id,
            preview: render_product_preview
        }
    }

  end

  def update_product_preview

    product = ShopifyAPI::Product.find(params[:product_id])
    img_base64 = params[:img]

    for img in product.images
      if img.position == 1
        _del_image(product, img.id)
        break
      end
    end

    # # upload new image
    update_img = _save_img(product, img_base64, {:position => 1})

    render json: {
        status: 200,
        data: {
            preview_type: 'Img',
            option_type: '',
            preview_data: {
                value: update_img.attributes[:src]
            },
            option_data: {}
        }
    }
  end

  def delete_product_preview

    product = ShopifyAPI::Product.find(params[:product_id])

    for img in product.images
      if img.position == 1
        # delete current image
        _del_image(product, img.id)
        break
      end
    end

    render json: {
        status: 200,
        data: []
    }
  end

  # PANELS
  def get_panels

    product_id = params[:product_id]
    panels = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_panels"})
    result_panels = []

    for pa in panels
      panel_data = JSON.parse(pa.value)
      result_panels.push({id: pa.id}.merge(panel_data))
    end

    render json: {
        status: 200,
        data: result_panels
    }
  end

  def add_panel

    product = ShopifyAPI::Product.find(params[:product_id])
    title = params[:title]
    description = params[:description]

    save_panel_data = {
        title: title,
        description: description
    }

    last_item = product.metafields.last
    item_add_key = last_item ? ['panel_next_of', last_item.id, rand(0..300)].join('_') : ['panel_0', rand(0..300)].join('_')

    meta_field = ShopifyAPI::Metafield.new({
                                               :description => 'Product customizer panels',
                                               :namespace => 'customizer_panels',
                                               :key => item_add_key,
                                               :value => JSON[save_panel_data],
                                               :value_type => 'string'
                                           })

    product.add_metafield(meta_field)
    meta_field_data = JSON.parse(meta_field.value)

    render json: {
        status: 200,
        data: {
            id: meta_field.id
        }.merge(meta_field_data)
    }
  end

  def update_panel

    panel_id = params[:panel_id]
    panel = ShopifyAPI::Metafield.find(panel_id)

    title = params[:title]
    description = params[:description]

    save_panel_data = {
        title: title,
        description: description
    }

    panel.value = JSON[save_panel_data]
    panel.save


    render json: {
        status: 200,
        data: {
            id: panel.id
        }.merge(save_panel_data)
    }
  end

  def delete_panel

    product = ShopifyAPI::Product.find(params[:product_id])
    product_id = product.id
    panel_id = params[:panel_id]

    _del_panel(product_id, panel_id)

    panels = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_panels"})
    categories = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_cat"})
    options = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_opt"})

    result_panels = []
    result_categories = []
    result_options = []

    for pa in panels
      panel_data = JSON.parse(pa.value)
      result_panels.push({id: pa.id}.merge(panel_data))
    end

    for category in categories
      category_data = JSON.parse(category.value)
      result_categories.push({id: category.id}.merge(category_data))
    end

    for option in options
      option_data = JSON.parse(option.value)
      result_options.push({id: option.id}.merge(option_data))
    end

    render json: {
        status: 200,
        data: {
            panel_id: panel_id,
            panels: result_panels,
            categories: result_categories,
            options: result_options
        }
    }
  end

  # CATEGORIES
  def get_categories

    render json: {
        status: 200,
        data: []
    }
  end

  def add_category

    product = ShopifyAPI::Product.find(params[:product_id])
    title = params[:title]
    description = params[:description]
    panel_id = params[:panel_id]
    parent_category_id = params[:parent_category_id]

    save_category_data = {
        title: title,
        description: description,
        panel_id: panel_id,
        parent_category_id: parent_category_id
    }

    last_item = product.metafields.last
    item_add_key = last_item ? ['cat_next_of', last_item.id, rand(0..300)].join('_') : ['cat_0', rand(0..300)].join('_')

    meta_field = ShopifyAPI::Metafield.new({
                                               :description => ['panel_id', panel_id].join('_'),
                                               :namespace => 'customizer_cat',
                                               :key => item_add_key,
                                               :value => JSON[save_category_data],
                                               :value_type => 'string'
                                           })

    product.add_metafield(meta_field)
    meta_field_data = JSON.parse(meta_field.value)

    render json: {
        status: 200,
        data: {
            id: meta_field.id
        }.merge(meta_field_data)
    }
  end

  def update_category

    category_id = params[:category_id]
    category = ShopifyAPI::Metafield.find(category_id)

    title = params[:title]
    description = params[:description]
    panel_id = params[:panel_id]
    parent_category_id = params[:parent_category_id]

    save_category_data = {
        title: title,
        description: description,
        panel_id: panel_id,
        parent_category_id: parent_category_id
    }

    category.value = JSON[save_category_data]
    category.save

    render json: {
        status: 200,
        data: {
            id: category_id
        }.merge(save_category_data)
    }
  end

  def delete_category

    product = ShopifyAPI::Product.find(params[:product_id])
    product_id = product.id
    category_id = params[:category_id]

    _del_category(product_id, category_id)

    categories = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_cat"})
    options = ShopifyAPI::Metafield.find(:all, :params => {:resource => "products", :resource_id => product_id, :namespace => "customizer_opt"})

    result_categories = []
    result_options = []

    for category in categories
      category_data = JSON.parse(category.value)
      result_categories.push({id: category.id}.merge(category_data))
    end

    for option in options
      option_data = JSON.parse(option.value)
      result_options.push({id: option.id}.merge(option_data))
    end

    render json: {
        status: 200,
        data: {
            category_id: category_id,
            categories: result_categories,
            options: result_options
        }
    }
  end

  # OPTIONS
  def get_options
    render json: {
        status: 200,
        data: []
    }
  end

  def add_option

    product = ShopifyAPI::Product.find(params[:product_id])

    category_id = params[:category_id]
    option_data = params[:option_data]
    preview_data = params[:preview_data]
    option_type = params[:option_type]
    preview_type = params[:preview_type]

    save_option_data = {
        category_id: category_id,
        option_type: option_type,
        preview_type: preview_type,
        option_data: option_data,
        preview_data: preview_data
    }

    last_item = product.metafields.last
    item_add_key = last_item ? ['opt_next_of', last_item.id, rand(0..300)].join('_') : ['opt_0', rand(0..300)].join('_')


    _save_option_images(product, save_option_data, false)

    meta_field = ShopifyAPI::Metafield.new({
                                               :description => ['category_id', category_id].join('_'),
                                               :namespace => 'customizer_opt',
                                               :key => item_add_key,
                                               :value => JSON[save_option_data],
                                               :value_type => 'string'
                                           })

    product.add_metafield(meta_field)
    meta_field_data = JSON.parse(meta_field.value)
    meta_field_data = _prepare_option(product, meta_field_data)

    render json: {
        status: 200,
        data: {
            id: meta_field.id
        }.merge(meta_field_data)
    }
  end

  def update_option

    option_id = params[:option_id]

    product = ShopifyAPI::Product.find(params[:product_id])
    option = ShopifyAPI::Metafield.find(option_id)
    current_option_data = JSON.parse(option.value)

    option_data = params[:option_data]
    preview_data = params[:preview_data]
    option_type = params[:option_type]
    preview_type = params[:preview_type]

    save_option_data = {
        option_data: option_data,
        preview_data: preview_data,
        option_type: option_type,
        preview_type: preview_type,
        category_id: current_option_data['category_id']
    }

    save_option_data = _save_option_images(product, save_option_data, current_option_data)

    option.value = JSON[save_option_data]
    option.save

    save_option_data = _prepare_option(product, save_option_data)

    render json: {
        status: 200,
        data: {
            id: option.id
        }.merge(save_option_data)
    }
  end

  def delete_option
    render json: {
        status: 200,
        data: {}
    }
  end

end