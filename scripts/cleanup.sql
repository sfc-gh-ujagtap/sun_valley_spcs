-- Sun Valley Database Cleanup Script
-- Use this to clean up or reset the Sun Valley database

-- Use the schema
USE DATABASE SUN_VALLEY;
USE SCHEMA Y2025;

-- Drop views first (due to dependencies)
DROP VIEW IF EXISTS SUN_VALLEY_COMPANY_BREAKDOWN;
DROP VIEW IF EXISTS SUN_VALLEY_STATUS_SUMMARY;

-- Drop the main table
DROP TABLE IF EXISTS SUNVALLEY_2025LIST_HYBRID;

-- Optionally drop the entire schema and database
-- Uncomment the lines below if you want to completely remove everything
-- DROP SCHEMA IF EXISTS Y2025;
-- DROP DATABASE IF EXISTS SUN_VALLEY;

-- Confirm cleanup
SELECT 'Cleanup completed' as status;
