-- Example user and role administration script
-- Adjust passwords and roles for your environment before running

-- Create roles for different responsibilities
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dba') THEN
    CREATE ROLE dba WITH NOLOGIN CREATEDB CREATEROLE REPLICATION;
  END IF;
END $$;

-- Create an application user
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
    CREATE ROLE app_user WITH LOGIN PASSWORD 'ChangeMe!';
  END IF;
END $$;

-- Grant privileges: adjust database names as needed
GRANT dba TO app_user;

-- Create a sample schema and limit privileges
CREATE SCHEMA IF NOT EXISTS app_schema AUTHORIZATION app_user;
REVOKE ALL ON SCHEMA app_schema FROM public;
GRANT USAGE ON SCHEMA app_schema TO app_user;

-- Example: give app_user privileges on a table (run after creating tables)
-- GRANT SELECT, INSERT, UPDATE ON my_table TO app_user;
