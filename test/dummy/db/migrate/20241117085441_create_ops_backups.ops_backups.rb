# This migration comes from ops_backups (originally 20241114173612)
class CreateOpsBackups < ActiveRecord::Migration[8.0]
  def change
    create_table :ops_backups do |t|
      t.string :name, null: false
      t.string :tag, null: false

      t.timestamps
    end
  end
end
