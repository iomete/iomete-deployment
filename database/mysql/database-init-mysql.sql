-- Create Databases
CREATE DATABASE IF NOT EXISTS iomete_core_db;
CREATE DATABASE IF NOT EXISTS iomete_iam_db;
CREATE DATABASE IF NOT EXISTS iomete_sql_db;
CREATE DATABASE IF NOT EXISTS iomete_iceberg_db;
CREATE DATABASE IF NOT EXISTS iomete_metastore_db;
CREATE DATABASE IF NOT EXISTS iomete_keycloak_db;
CREATE DATABASE IF NOT EXISTS iomete_ranger_db;
CREATE DATABASE IF NOT EXISTS iomete_catalog_db;

-- Create User
CREATE USER IF NOT EXISTS iomete_user@'%' IDENTIFIED BY 'iomete_pass';

-- Grant Privileges
GRANT ALL ON iomete_core_db.* TO iomete_user;
GRANT ALL ON iomete_iam_db.* TO iomete_user;
GRANT ALL ON iomete_sql_db.* TO iomete_user;
GRANT ALL ON iomete_iceberg_db.* TO iomete_user;
GRANT ALL ON iomete_metastore_db.* TO iomete_user;
GRANT ALL ON iomete_keycloak_db.* TO iomete_user;
GRANT ALL ON iomete_ranger_db.* TO iomete_user;
GRANT ALL ON iomete_catalog_db.* TO iomete_user;
