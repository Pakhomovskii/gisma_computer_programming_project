#!/bin/bash

# PostgreSQL connection details
DB_USER="postgres"  # Replace with your PostgreSQL username
DB_PASSWORD="postgres"  # Replace with your PostgreSQL password
DB_HOST="localhost"  # Default host for PostgreSQL
DB_NAME="save_energy_project"  # Name of the database to create

# Export password to be used by psql
export PGPASSWORD="$DB_PASSWORD"

# Function to execute SQL commands
execute_sql() {
    local db_name="$1"
    local sql_command="$2"
    echo "Executing SQL on $db_name: $sql_command"
    psql -h "$DB_HOST" -U "$DB_USER" -d "$db_name" -c "$sql_command"
}

# Create a new database
echo "Creating database: $DB_NAME"
execute_sql "postgres" "CREATE DATABASE \"$DB_NAME\";"

# Enable UUID extension (if not already enabled)
echo "Enabling UUID extension..."
execute_sql "$DB_NAME" "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

CREATE_USERS_TABLE_SQL="
CREATE TABLE IF NOT EXISTS users (
    user_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);"

# Define SQL commands to create tables with UUID


CREATE_ENERGY_USAGE_TABLE_SQL="
CREATE TABLE IF NOT EXISTS energy_usage (
    id SERIAL PRIMARY KEY,
    user_uuid UUID NOT NULL,
    average_monthly_bill DECIMAL NOT NULL,
    average_natural_gas_bill DECIMAL NOT NULL,
    monthly_fuel_bill DECIMAL NOT NULL,
    FOREIGN KEY (user_uuid) REFERENCES users(user_uuid),
    UNIQUE(user_uuid)  -- Assuming each user has a unique energy usage record; adjust if necessary
);
"
CREATE_BUSINESS_TRAVEL_TABLE_SQL="
CREATE TABLE IF NOT EXISTS business_travel (
    id SERIAL PRIMARY KEY,
    user_uuid UUID NOT NULL,
    kilometers_per_year DECIMAL NOT NULL,
    average_efficiency_per_100km DECIMAL NOT NULL,
    FOREIGN KEY (user_uuid) REFERENCES users(user_uuid),
    UNIQUE(user_uuid)  -- Corrected by adding a comma before UNIQUE
);"

CREATE_WASTE_SECTOR_TABLE_SQL="
CREATE TABLE IF NOT EXISTS waste_sector (
    id SERIAL PRIMARY KEY,
    user_uuid UUID NOT NULL,
    waste_kg DECIMAL NOT NULL,
    recycled_or_composted_kg DECIMAL NOT NULL,
    FOREIGN KEY (user_uuid) REFERENCES users(user_uuid),
    UNIQUE(user_uuid)  -- Corrected by adding a comma before UNIQUE
);"


# Note: No changes needed in other tables since they already reference user_uuid

# Execute SQL commands to create tables in the new database
echo "Creating tables in $DB_NAME"
execute_sql "$DB_NAME" "$CREATE_USERS_TABLE_SQL"
execute_sql "$DB_NAME" "$CREATE_WASTE_SECTOR_TABLE_SQL"
execute_sql "$DB_NAME" "$CREATE_BUSINESS_TRAVEL_TABLE_SQL"
execute_sql "$DB_NAME" "$CREATE_ENERGY_USAGE_TABLE_SQL"
# Execute other table creation commands as before...

echo "Database and tables created successfully."