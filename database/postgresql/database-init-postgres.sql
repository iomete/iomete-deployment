-- Create Databases
CREATE DATABASE iomete_core_db;
CREATE DATABASE iomete_iam_db;
CREATE DATABASE iomete_sql_db;
CREATE DATABASE iomete_iceberg_db;
CREATE DATABASE iomete_metastore_db;
CREATE DATABASE iomete_keycloak_db;
CREATE DATABASE iomete_ranger_db;
CREATE DATABASE iomete_catalog_db;

-- Create User
CREATE USER iomete_user WITH PASSWORD 'iomete_pass';

-- Grant Privileges
GRANT ALL PRIVILEGES ON DATABASE iomete_core_db TO iomete_user;
GRANT ALL PRIVILEGES ON DATABASE iomete_iam_db TO iomete_user;
GRANT ALL PRIVILEGES ON DATABASE iomete_sql_db TO iomete_user;
GRANT ALL PRIVILEGES ON DATABASE iomete_iceberg_db TO iomete_user;
GRANT ALL PRIVILEGES ON DATABASE iomete_metastore_db TO iomete_user;
GRANT ALL PRIVILEGES ON DATABASE iomete_keycloak_db TO iomete_user;
GRANT ALL PRIVILEGES ON DATABASE iomete_ranger_db TO iomete_user;
GRANT ALL PRIVILEGES ON DATABASE iomete_catalog_db TO iomete_user;

-- Switch to created databases and grant privileges on public schema to the user (repeat for each database)
GRANT ALL PRIVILEGES ON SCHEMA public TO iomete_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO iomete_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO iomete_user;
