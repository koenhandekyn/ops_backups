Rails.application.config.to_prepare do
  ActiveStorage::Current.url_options = { host: 'http://localhost:3000' }
end
