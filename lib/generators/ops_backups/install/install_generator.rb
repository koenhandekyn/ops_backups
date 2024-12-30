class OpsBackups::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  desc "Adds a storage service configuration to storage.yml"

  # it seems the migrations already are available in the host app
  # def copy_migrations
  #   rake "railties:install:migrations FROM=ops_backups"
  #   say "Migrations copied to your application.", :green
  # end

  def add_storage_service
    storage_file = Rails.root.join("config", "storage.yml")

    if File.exist?(storage_file)
      service_config = <<~YAML

        backups:
          service: Disk
          root: <%= Rails.root.join("storage") %>
          # service: S3
          # access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
          # secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
          # region: <%= ENV['AWS_REGION'] %>
          # bucket: allcrux-backups
      YAML

      append_to_file storage_file, service_config
      say "Added 'backups' service to storage.yml.", :green
    else
      say "config/storage.yml not found. Please create it and re-run this generator.", :red
    end
  end

  def add_recurring_jobs
    recurring_file = Rails.root.join("config", "recurring.yml")

    if File.exist?(recurring_file)
      recurring_config = <<~YAML.lines.map { |line| "  #{line}" }.join
        backup_db:
          class: OpsBackups::BackupDbJob
          args: [tag: "db_pg_backup", cleanup: "retain_tiered"]
          schedule: every hour
      YAML

      append_to_file recurring_file, recurring_config
      say "Added 'recurring' jobs to recurring.yml.", :green
    else
      say "config/recurring.yml not found. Please create it and re-run this generator.", :red
    end

    # # copy the admin/backup.rb file to app/admin/ops_backups/backup.rb
    # def copy_admin_backup
    #   copy_file "admin/backup.rb", Rails.root.join("app", "admin", "ops_backups", "backup.rb")
    #   say "Copied admin/backup.rb to app/admin/ops_backups/backup.rb.", :green
    # end
  end
end
