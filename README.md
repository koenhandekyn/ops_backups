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

# Scripts

`pgdb` is a script that can be used to backup and restore a postgres database and wraps pg_dump and pg_restore in the context of [Kamal](https://kamal-deploy.org/) for ease of use. Environment here coresponds to the destination in Kamal.

```
Usage: pgdb <command> <environment> [<additional_args>]

Available commands:
  console <environment>                   - Opens a database console for the specified environment.
  create <environment>                    - Creates a new database for the specified environment.
  revert <environment> <backup_db_name>   - Reverts the database to a specified backup.
  backup <environment>                    - Creates a clone of the remote database as a backup on the server.
  backup:local <environment>              - Backs up the remote database to a local dump file.
  drop <environment>                      - Drops the database of the specified environment after confirmation.
  pull <environment|url> [local_db_name]  - Pulls the remote database to a local database with an optional custom name (optional).
  push <environment> <local_db_name>      - Pushes a local database to the remote environment, creating a backup of the remote.
  rename <environment> [new_db_name]      - Renames the main database of the specified environment, optionally using a new name (optional).
  copy <source_env> <target_env>          - Copies a database from one environment to another, with backup of the target database.
  list <environment>                      - Lists databases for the base URL associated with the environment.

set EXCLUDE_TABLE_DATA to exclude data from specific tables on export
e.g. EXCLUDE_TABLE_DATA=versions   bin/pgdb pull staging
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
