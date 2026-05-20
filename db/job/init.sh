#!/bin/bash
set -e

PG_DBNAME=job
PG_USER=postgres
export PGPASSWORD=postgres # Note: avoids password prompt

# Original parent directory of the current script's location
DIR=/dedalus/db/job
# Path to already existing imdb tar file
IMDB_FILE=$DIR/imdb.tgz
# Writable temp folder
TMP_DIR=/tmp

# Parse the JOB CSV files
if [ -f "$IMDB_FILE" ]; then
    echo "Using provided IMDB file: $IMDB_FILE"
    tar xz -f $IMDB_FILE --directory $TMP_DIR
else
    echo "No file provided. Downloading IMDB dataset..."
    wget \
        --progress=dot:giga \
        -O $TMP_DIR/imdb.tgz \
        https://event.cwi.nl/da/job/imdb.tgz

    tar xz -f $TMP_DIR/imdb.tgz --directory $TMP_DIR
fi

execute="psql -v ON_ERROR_STOP=1 -d $PG_DBNAME -U $PG_USER -a"

# Delete everything for idempotency
$execute -c "DROP SCHEMA public CASCADE;"
$execute -c "CREATE SCHEMA public;"
$execute -c "GRANT ALL ON SCHEMA public TO $PG_USER;"
$execute -c "GRANT ALL ON SCHEMA public TO public;"

# Enable pg_hint_plan extension
$execute -c "CREATE EXTENSION IF NOT EXISTS pg_hint_plan;"

# Create the relations
$execute -q -f "$TMP_DIR/schematext.sql"

# Upload the CSV files
for path in $TMP_DIR/*.csv; do
    filename="$(cut -d '/' -f3 <<<"$path")"
    table="$(cut -d '.' -f1 <<<"$filename")"
    sed -i 's/\\\\\"/"/g' $path  # Removes \\" with "
    sed -i s/\\\\\"/\'/g $path  # Replaces \" with \'
    $execute -c "\COPY $table FROM '$path' DELIMITER ',' CSV;"
done

# Add the foreign keys
$execute -q -f "$DIR/foreign_keys.sql"
# Add indexes on the foreign keys
$execute -q -f "$DIR/fkindexes.sql"

# Update the statistics
$execute -c "ANALYZE;"

# Show enabled extensions for the database
$execute -c "SHOW shared_preload_libraries;"