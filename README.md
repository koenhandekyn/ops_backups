# OpsBackups

A Ruby gem that provides a simple way to backup (self)-hosted postgres databases to
ActiveStorage services like S3, Google Cloud Storage, etc.

## Usage

## Installation

```bash
bundle add ops_backups
# install migrations
# configure solid queu recurring job for a basic backup
rails generate ops_backups:install
```

# ActiveAdmin Integration

If you are using ActiveAdmin, you can manage your backups through the admin interface. The generator rails generate ops_backups:activeadmin will create the necessary example configuration.

```bash
# add an active admin resource
rails generate ops_backups:activeadmin
```

## Available Actions

- Download Backup: Download the backup file.
- Create Versioned Backup: Create a new versioned backup.
- Create Unversioned Backup: Create a new unversioned backup, excluding specific tables.



## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
