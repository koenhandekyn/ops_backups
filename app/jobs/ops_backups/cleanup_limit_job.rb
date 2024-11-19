# frozen_string_literal: true

# Cleanup job for limit backup policy
class OpsBackups::CleanupLimitJob < ApplicationJob
  queue_as :operations

  # @param [String] tag
  # @param [Integer] limit
  # @return [void]
  #
  # @example Tasks::CleanupLimit.perform_now(tag: "db_pg_full", limit: 14)
  def perform(tag: "db_pg_full", limit: 14)
    OpsBackups::Backup.retain_last_limit_cleanup_policy(tag: tag, limit: limit)
  end
end
