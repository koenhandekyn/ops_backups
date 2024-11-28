module OpsBackups
  class Backup < ActiveRecord::Base
    # has_one_attached :backup_file, service: :backup_storage
    has_one_attached :backup_file, service: :backups
    self.table_name = "ops_backups"

    default_scope { order(updated_at: :desc) }

    def self.ransackable_attributes(auth_object = nil)
      [ "created_at", "id", "name", "new_id", "tag", "updated_at" ]
    end

    def db_pg_backup(tag: nil, exclude_tables: [])
      db_url = ENV["DATABASE_URL"]
      tag ||= exclude_tables.empty? ? "db_pg_full" : "db_pg_partial" # if tag.empty?
      self.tag = tag
      self.name = "pg_#{db_url.split('/').last}_backup_#{Time.now.to_i}.dump"
      save!
      Rails.logger.info("Backing up database")
      # exclude_tables = []
      filename = self.name
      Tempfile.open("pgbackup") do |tempfile|
        begin
          excluded_tables_param = exclude_tables.map { |table| "--exclude-table-data=\#{table}" }.join(" ")
          command = [ "pg_dump", "--no-owner", excluded_tables_param, "-v", "-Fc", "-f", tempfile.path, db_url ].reject(&:empty?)

          stdout, stderr, status = Open3.capture3(*command)

          if status.success?
            Rails.logger.info("PgBackup successful: #{stdout}")
            backup_file.attach io: File.open(tempfile.path), filename:, content_type: "application/octet-stream"
          else
            error_message = "PgBackup failed: #{stderr.strip}"
            Rails.logger.error(error_message)
            raise "PgBackup command failed: #{error_message}"
          end
        rescue StandardError => e
          Rails.logger.error("Failed to backup database: \#{e.message}")
          raise
        end
      end
    end

    # Keep all the backups of the last day
    # Keep the last backup of each day in the last week (except the last day)
    # Keep the last backup of each week in the last month (except the last week)
    # Keep the last backup of each month before the last month
    def self.retain_tiered_cleanup_policy(tag: "")
      week = where(created_at: 1.week.ago..1.day.ago)
        .group_by { |b| b.created_at.to_date }
      month = where(created_at: 1.month.ago..1.week.ago)
        .group_by { |b| b.created_at.beginning_of_week }
      older = where(created_at: 1.year.ago..1.month.ago)
        .group_by { |b| b.created_at.beginning_of_month }

      backups = week.merge(month).merge(older)

      ids = backups.flat_map do |_, group|
        group.sort_by(&:created_at).reverse.drop(1).pluck(:id)
      end

      records = where(id: ids)
      records = records.where(tag: tag) if tag.present?
      records.destroy_all
    end

    # Keep the last 14 backups
    def self.retain_last_limit_cleanup_policy(limit: 14, tag: "")
      records = all
      records = records.where(tag: tag) if tag.present?
      records = records.order(updated_at: :desc).offset(limit)
      records.destroy_all
    end
  end
end
