module OpsBackups
  class BackupsController < ApplicationController
    def index
      @backups = OpsBackups::Backup.limit(20)
    end

    def download
      backup = OpsBackups::Backup.find(params[:id])
      redirect_to backup.backup_file.url(disposition: :attachment), allow_other_host: true
    end
  end
end
