module OpsBackups
  class BackupsController < ApplicationController
    def index
      @backups = OpsBackups::Backup.all.order(updated_at: :desc)
      @jobs = jobs
    end

    def download
      backup = OpsBackups::Backup.find(params[:id])
      redirect_to backup.backup_file.url(disposition: :attachment), allow_other_host: true
    end

    def destroy
      backup = OpsBackups::Backup.find(params[:id])
      backup.destroy
      redirect_to backups_url, notice: "#{backup} destroyed."
    end

    def trigger_job
      job_name = params[:job_name]
      job_config = jobs[job_name]

      job_class = job_config["class"].constantize
      args = job_config["args"] || []

      Rails.logger.info "Triggering job: #{job_name} with args: #{args.reduce({}, :merge).symbolize_keys}"

      job_class.perform_later(args.reduce({}, :merge).symbolize_keys)

      redirect_to backups_url, notice: "#{job_name} triggered successfully."
    end

    private

    def jobs
      jobs = YAML.load_file(Rails.root.join("config", "recurring.yml"))[Rails.env]
      jobs&.select { |k, v| v["class"].start_with?("OpsBackups") }
    end
  end
end
