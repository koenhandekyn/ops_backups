class CreateOpsBackups < ActiveRecord::Migration[5.0]
  def change
    # check if the table already exists
    return if table_exists?(:ops_backups)
    create_table :ops_backups do |t|
      t.string :name, null: false
      t.string :tag, null: false

      t.timestamps
    end
  end
end
