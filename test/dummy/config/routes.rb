Rails.application.routes.draw do
  mount OpsBackups::Engine => "/ops_backups"
end
