OpsBackups::Engine.routes.draw do
  get 'backups', to: 'backups#index'
  get 'backups/:id/download', to: 'backups#download', as: 'download_backup'
end
