class OpsBackups::ActiveadminGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  desc "Copies the ActiveAdmin backup configuration to your application."

  def copy_admin_backup
    copy_file "backup.rb", Rails.root.join("app", "admin", "ops_backups", "backup.rb")
    say "Copied admin/backup.rb to app/admin/ops_backups/backup.rb.", :green
  end
end
