# typed: true
# frozen_string_literal: true

class OpsBackups::BackupDbJob < ApplicationJob
  queue_as :operations

  # perform a full backup of the database
  # @param tag [String] the tag to assign to the backup
  # @param exclude_tables [Array<String>] the list of tables to exclude from the backup
  # @param cleanup_policy [String] the cleanup policy to apply to the backup, one of "retain_tiered_cleanup_policy" or "retain_last_limit_cleanup_policy"
  def perform(options = {})
    exclude_tables = options[:exclude_tables] || []
    tag = options[:tag] || (exclude_tables.empty? ? "db_pg_full" : "db_pg_partial")
    cleanup = options[:cleanup]
    Rails.logger.info "Performing backup with tag: #{tag} and exclude_tables: #{exclude_tables}"
    OpsBackups::Backup.new.db_pg_backup(exclude_tables:, tag:)
    OpsBackups::Backup.send("#{cleanup}_cleanup_policy", tag: tag) if cleanup.present?
  end
end
