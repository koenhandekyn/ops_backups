# frozen_string_literal: true

# Cleanup job for tiered backup policy
class OpsBackups::CleanupTieredJob < ApplicationJob
  queue_as :operations

  # @param [String] tag
  # @return [void]
  #
  # @example Tasks::CleanupTiered.perform_now(tag: "db_pg_full")
  def perform(tag: "db_pg_full")
    OpsBackups::Backup.retain_tiered_cleanup_policy(tag: tag)
  end
end
