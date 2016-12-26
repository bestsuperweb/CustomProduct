Rails.application.configure do

  config.app_path = 'https://shopifycustomizer.herokuapp.com/'
  config.assets.cdn_path = 'https://shopifycustomizer.herokuapp.com/dist/'
  config.assets.api_prefix = '/api/'

  # config.app_path = 'http://localhost:3000'
  # config.assets.cdn_path = 'http://localhost:8082/dist/'

  # PROD
  # config.cache_classes = true
  # config.eager_load = true
  # config.consider_all_requests_local = false
  # config.action_controller.perform_caching = true
  # config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  # config.assets.compile = false
  # config.assets.digest = true
  # config.log_level = :debug
  # config.i18n.fallbacks = true
  # config.active_support.deprecation = :notify
  # config.log_formatter = ::Logger::Formatter.new
  # config.active_record.dump_schema_after_migration = false

  # DEV

  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true
end
