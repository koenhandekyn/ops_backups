class OpsBackups::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  desc "Copies migrations and adds a storage service configuration to storage.yml"

  def copy_migrations
    rake "railties:install:migrations FROM=ops_backups"
    say "Migrations copied to your application.", :green
  end

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
      recurring_config = <<~YAML.lines.map { |line| "\t#{line}" }.join
        backup_db:
          class: OpsBackups::BackupDbJob
          args: [tag: "db_pg_backup", cleanup: "retain_tiered_cleanup_policy"]
          schedule: every hour
      YAML

      append_to_file recurring_file, recurring_config
      say "Added 'recurring' jobs to recurring.yml.", :green
    else
      say "config/recurring.yml not found. Please create it and re-run this generator.", :red
    end
  end
end
