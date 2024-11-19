ActiveAdmin.register OpsBackups::Backup do
  menu parent: "Ops", label: I18n.t("admin.ops.backup")

  # Set the default sort order
  config.sort_order = "updated_at DESC"

  actions :index, :destroy

  filter :name
  filter :tag

  index title: I18n.t("admin.ops.backup") do
    selectable_column
    column :name do |backup|
      link_to(backup.name, download_backup_admin_ops_backups_backup_path(backup), class: "member_link")
    end
    column :tag
    column :size do |backup|
      backup.backup_file.attached? ? number_to_human_size(backup.backup_file.byte_size) : "N/A"
    end
    column :updated_at
    column :duration do |backup|
      Time.at((backup.updated_at - backup.created_at)).utc.strftime("%H:%M:%S")
    end
    actions
  end

  member_action :download_backup, method: :get do
    redirect_to resource.backup_file.url(disposition: :attachment), allow_other_host: true
  end

  # an action that creates a new backup
  collection_action :backup_db, method: :post do
    OpsBackups::BackupDbJob.perform_later(tag: "db_pg_full")
    redirect_to admin_ops_backups_backups_path, notice: I18n.t("admin.ops.backup_scheduled")
  end

  # add a button to the top of the index page
  action_item :backup_db, only: :index do
    link_to(I18n.t("admin.ops.backup_db"), backup_db_admin_ops_backups_backups_path, method: :post, class: "action-item-button")
  end
end
