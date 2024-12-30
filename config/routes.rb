OpsBackups::Engine.routes.draw do
  get "backups", to: "backups#index"
  get "backups/:id/download", to: "backups#download", as: "download_backup"
  delete "backups/:id", to: "backups#destroy", as: "backup"
  post "backups/trigger_job", to: "backups#trigger_job", as: "trigger_job"
end
