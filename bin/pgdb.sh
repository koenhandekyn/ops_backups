#!/bin/bash

# Function to calculate the backup database name
backup_db_name() {
  local target_db_name="$1"
  local current_date=$(date +%Y%m%d)
  local timestamp=$(date +%H%M%S)
  echo "${target_db_name}_${current_date}_${timestamp}"
}

# Function to rename a PostgreSQL database
# Usage: db_rename <db_url> <old_db_name> <new_db_name>
db_rename() {
  local db_url="$1"
  local old_db_name="$2"
  local new_db_name="$3"

  if [[ -z "$old_db_name" || -z "$new_db_name" || -z "$db_url" ]]; then
    echo "Usage: rename <db_url> <old_db_name> <new_db_name>"
    exit 1
  fi

  echo "Renaming database from $old_db_name to $new_db_name on $db_url"
  # Run the ALTER DATABASE command to rename the database
  psql "$db_url" -c "ALTER DATABASE \"$old_db_name\" RENAME TO \"$new_db_name\";"
}

# Function to create a PostgreSQL database
# Usage: db_create <db_url> <new_db_name>
db_create() {
  local db_url="$1"
  local new_db_name="$2"

  if [[ -z "$new_db_name" || -z "$db_url" ]]; then
    echo "Usage: create <db_url> <new_db_name>"
    exit 1
  fi

  echo "Creating database $new_db_name on $db_url"
  # Run the CREATE DATABASE command to rename the database
  psql "$db_url" -c "CREATE DATABASE \"$new_db_name\";"
}

# Function for pulling a database from a remote server to the local machine
# Usage: db_pull <db_url> <db_name>
db_pull() {
  local db_url="$1"
  local db_name="$2"
  local dump_file="${db_name}.dump"

  # Step 1: Dump the remote database
  echo "Dumping database from $db_url to $dump_file..."

  local exclude=""
  if [[ -n "$EXCLUDE_TABLE_DATA" ]]; then
    exclude="--exclude-table-data=$EXCLUDE_TABLE_DATA"
  fi
  pg_dump --no-owner -v -Fc $exclude -f "$dump_file" "$db_url"

  # Step 2: Check if local database exists, prompt for confirmation, and drop if confirmed
  if psql -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
    read -p "Database $db_name already exists. Do you want to drop it and recreate? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
      echo "Aborting..."
      exit 1
    fi
    echo "Dropping existing database..."
    dropdb "$db_name"
  fi

  # Step 3: Create a new local database
  echo "Creating local database..."
  createdb "$db_name"

  # Step 4: Restore the dump to the new local database
  echo "Restoring database..."
  pg_restore --no-owner --no-comments -v -d "postgres://localhost/$db_name" "$dump_file"

  echo "Database pull completed: $db_name"
}


# Function for "push" subcommand
# Usage: db_push <local_db_name> <remote_db_url>
db_push() {
  local local_db_name="$1"
  local remote_db_url="$2"
  local dump_file="$(backup_db_name "$local_db_name").dump"

  # Dump the local database
  echo "Dumping local database..."
  local exclude=""
  if [[ -n "$EXCLUDE_TABLE_DATA" ]]; then
    exclude="--exclude-table-data=$EXCLUDE_TABLE_DATA"
  fi
  echo pg_dump --no-owner -v -Fc $exclude -f $dump_file postgres://localhost/$local_db_name
  pg_dump --no-owner -v -Fc $exclude -f $dump_file postgres://localhost/$local_db_name

  # Restore the dump to the new remote database
  echo pg_restore --no-owner --no-comments -v -d $remote_db_url $dump_file
  pg_restore --no-owner --no-comments -v -d $remote_db_url $dump_file

  echo "Database push completed: $local_db_name"
}

# Function for copying a database from one server to another
# Usage: db_copy <source_db_url> <target_db_url>
db_copy() {
  local source_db_url="$1"
  local target_db_url="$2"
  local current_date=$(date +%Y%m%d)
  local timestamp=$(date +%H%M%S)
  local source_db_name="${source_db_url##*/}"
  local target_db_name="${target_db_url##*/}"
  local dump_file="${source_db_name}_${target_db_name}_${current_date}_${timestamp}.dump"

  # Step 1: Dump the source database
  echo "Dumping source database..."
  local exclude=""
  if [[ -n "$EXCLUDE_TABLE_DATA" ]]; then
    exclude="--exclude-table-data=$EXCLUDE_TABLE_DATA"
  fi
  pg_dump --no-owner -v -Fc $exclude -f "$dump_file" "$source_db_url"

  # stop if the dump failed
  if [[ $? -ne 0 ]]; then
    echo "Dump failed. Aborting..."
    exit 1
  fi

  # Step 2: Create the target database (and backup if needed)
  local backup_db_name=$(backup_db_name "$target_db_name")
  local source_base_url="${source_db_url%/*}"
  local target_base_url="${target_db_url%/*}"
  db_rename "$target_base_url" "$target_db_name" "$backup_db_name"
  echo "Creating new target database: $target_db_name..."
  psql "$target_base_url" -c "CREATE DATABASE \"$target_db_name\";"

  # Step 3: Restore the dump to the target database
  echo "Restoring dump to target database..."
  pg_restore --no-owner --no-comments -v -d "$target_db_url" "$dump_file"

  echo "Database copy completed: $source_db_name to $target_db_name"
}

# function to rename a database
# Usage: db_rename <base_url> <old_name> <new_name>
db_rename() {
  local base_url="$1"
  local old_name="$2"
  local new_name="$3"
  # Run the ALTER DATABASE command to rename the database
  psql "$base_url" -c "ALTER DATABASE \"$old_name\" RENAME TO \"$new_name\";"
}

# function to clone a database on the server
# Usage: db_clone_on_server <base_url> <db_name> <clone_db_name:optional>
db_clone_on_server() {
  local base_url="$1"
  local db_name="$2"
  # if the third param is available, use it as the backup db name
  # else append current_date to db_name
  if [[ -n "$3" ]]; then
    local clone_db_name="$3"
  else
    local clone_db_name=$(backup_db_name "$db_name")
  fi
  psql "$base_url" -c "CREATE DATABASE \"$clone_db_name\" WITH TEMPLATE \"$db_name\";"
  # check if the clone db was created
  if psql "$base_url" -lqt | cut -d \| -f 1 | grep -qw "$clone_db_name"; then
    echo "Database $db_name clones as $clone_db_name"
  fi
}

# Function to extract DATABASE_URL from the secrets file
fetch_db_url() {
  local env="$1"

  # If the env starts with postgres://, return it as is
  if [[ "$env" == postgres://* ]]; then
    echo "$env"
    return
  fi

  local secrets_file=".kamal/secrets.${env}"

  if [[ ! -f "$secrets_file" ]]; then
    echo "Secrets file not found: $secrets_file"
    exit 1
  fi

  # Extract DATABASE_URL from the secrets file
  local db_url=$(awk -F '=' '/^DATABASE_URL=/{print $2}' "$secrets_file")

  if [[ -z "$db_url" ]]; then
    echo "DATABASE_URL not found in $secrets_file"
    exit 1
  fi

  echo "$db_url"
}

command="$1"
env="$2"
current_date=$(date +%Y%m%d)
timestamp=$(date +%H%M%S)

# Fetch the DATABASE_URL from the secrets file
db_url=$(fetch_db_url "$env")
# Extract everything before the last '/'
base_url="${db_url%/*}"
# Extract the database name after the last '/'
db_name="${db_url##*/}"

case "$command" in
console)
  echo "url: $db_url"
  psql "$db_url"
  ;;

copy)
  if [[ $# -lt 3 ]]; then
    echo "Usage: pgdb copy <source_environment> <target_environment>"
    exit 1
  fi

  source_environment="$2"
  target_environment="$3"

  kamal app stop -d "$source_environment"
  kamal app stop -d "$target_environment"

  # Fetch the source and target DATABASE_URLs
  source_db_url=$db_url
  target_db_url=$(fetch_db_url "$3")

  source_base_url="${source_db_url%/*}"
  target_base_url="${target_db_url%/*}"

  # if source and target base are the same, copy on the server
  # else copy between servers using pg_dump and pg_restore
  if [[ "$source_base_url" == "$target_base_url" ]]; then
    echo "Renaming current target database from $3 to $3_${current_date}_${timestamp}"
    backup_db_name=$(backup_db_name "$3")
    db_rename "$base_url" "$3" "$backup_db_name"
    # echo "Cloning database from $2 to $3"
    db_clone_on_server "$base_url" "$2" "$3"
  else
    # Copy the source DB to the target DB
    db_copy "$source_db_url" "${target_db_url}"
  fi

  kamal app boot -d "$source_environment"
  kamal app boot -d "$target_environment"
  ;;

pull)
  if (( $# < 2 || $# > 3 )); then
    echo "Usage: pgdb pull <environment> <local_db_name:optional>"
    exit 1
  fi
  if [[ -n "$3" ]]; then
    local_db_name="$3"
  else
    local_db_name=$(backup_db_name "$env")
  fi
  db_pull "$db_url" "$local_db_name"
  ;;

push)
  if [[ $# -lt 3 ]]; then
    echo "Usage: pgdb push <environment> <local_db_name>"
    exit 1
  fi
  local_db_name="$3"
  backup_db_name=$(backup_db_name "$db_name")

  kamal app stop -d "$env"
  db_rename "$base_url" "$db_name" "$backup_db_name"
  db_create "$base_url" "$db_name"
  db_push "$local_db_name" "$db_url"
  kamal app boot -d "$env"
  ;;

rename)
  if (( $# < 2 || $# > 3 )); then
    echo "Usage: pgdb rename <environment> <new_db_name:optional>"
    exit 1
  fi

  # if $3 present, use it as new_db_name else append current_date to db_name
  if [[ -n "$3" ]]; then
    new_db_name="$3"
  else
    new_db_name="${db_name}_${current_date}"
  fi

  db_rename "$base_url" "$db_name" "$new_db_name"
  ;;

list)
  echo "Listing databases for $base_url"
  echo
  psql "$base_url" -c "\l" | grep "$db_name"
  ;;

drop)
  echo "Dropping database $db_name"
  # ask for confirmation
  read -p "Are you sure you want to drop the database $db_name? (y/n): " -n 1 -r
  # abort if not confirmed
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Aborted!"
    exit 1
  fi
  psql "$base_url" -c "DROP DATABASE \"$db_name\";"
  ;;

backup:local)
  echo "Backing up database $db_name on the remote to a local dump"
  backup_db_name=$(backup_db_name "$db_name")
  db_pull "$db_url" "$backup_db_name"
  ;;

backup)
  echo "Backing up database $db_name on the remote"
  kamal app stop -d "$env"
  db_clone_on_server "$base_url" "$db_name"
  kamal app boot -d "$env"
  ;;

revert)
  echo "Reverting database $db_name from $3"
  # ask for confirmation
  read -p "Are you sure you want to revert the database $db_name to $3? (y/n): " -n 1 -r
  # abort if not confirmed
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted!"
    exit 1
  fi
  # check if the chosen db exists
  if ! psql "$base_url" -lqt | cut -d \| -f 1 | grep -qw "$3"; then
    echo "Database $3 does not exist, aborting the revert!"
    exit 1
  fi
  kamal app stop -d "$env"
  # clone to the default backup name
  db_clone_on_server "$base_url" "$db_name"
  # drop the current db
  psql "$base_url" -c "DROP DATABASE \"$db_name\";"
  # rename the chosen db to the original db name
  db_rename "$base_url" "$db_name" "$3"
  kamal app boot -d "$env"
  ;;

create)
  db_create "$base_url" "$env"
  ;;

*)
  echo "Unknown command: $command"
  echo "Usage: pgdb <command> <environment> [<additional_args>]"
  echo
  echo "Available commands:"
  echo "  console <environment>                   - Opens a database console for the specified environment."
  echo "  create <environment>                    - Creates a new database for the specified environment."
  echo "  revert <environment> <backup_db_name>   - Reverts the database to a specified backup."
  echo "  backup <environment>                    - Creates a clone of the remote database as a backup on the server."
  echo "  backup:local <environment>              - Backs up the remote database to a local dump file."
  echo "  drop <environment>                      - Drops the database of the specified environment after confirmation."
  echo "  pull <environment|url> [local_db_name]  - Pulls the remote database to a local database with an optional custom name (optional)."
  echo "  push <environment> <local_db_name>      - Pushes a local database to the remote environment, creating a backup of the remote."
  echo "  rename <environment> [new_db_name]      - Renames the main database of the specified environment, optionally using a new name (optional)."
  echo "  copy <source_env> <target_env>          - Copies a database from one environment to another, with backup of the target database."
  echo "  list <environment>                      - Lists databases for the base URL associated with the environment."
  echo
  echo "set EXCLUDE_TABLE_DATA to exclude data from specific tables on export"
  echo "e.g. EXCLUDE_TABLE_DATA=versions   bin/pgdb pull staging"
  exit 1
  ;;
esac
