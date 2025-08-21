-- Minimal Sun Valley 2025 Database Setup
-- Creates only the essential table structure with basic test data

-- Create database and schema
CREATE DATABASE IF NOT EXISTS SUN_VALLEY;
CREATE SCHEMA IF NOT EXISTS SUN_VALLEY.Y2025;

-- Use the schema
USE DATABASE SUN_VALLEY;
USE SCHEMA Y2025;

-- Create the main hybrid table
CREATE OR REPLACE HYBRID TABLE SUNVALLEY_2025LIST_HYBRID (
    ID NUMBER AUTOINCREMENT,
    NAME VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    TITLE VARCHAR(16777216),
    NEW VARCHAR(16777216),
    STATUS VARCHAR(16777216),
    PRIMARY KEY (ID)
);

-- Insert minimal test data
INSERT INTO SUNVALLEY_2025LIST_HYBRID (NAME, COMPANY, TITLE, NEW, STATUS) VALUES
    ('Test User 1', 'TechCorp', 'CEO', 'Sample contact', 'Confirmed'),
    ('Test User 2', 'DataFlow Inc', 'CTO', 'Demo entry', 'Pending'),
    ('Test User 3', 'AI Innovations', 'Founder', 'New connection', 'n/a'),
    ('Test User 4', 'CloudFirst', 'VP Engineering', 'Meeting scheduled', 'Investor meeting'),
    ('Test User 5', 'StartupXYZ', 'Product Manager', 'Follow up needed', 'Find at event');

-- Verify setup
SELECT 'Total Contacts' as metric, COUNT(*) as value FROM SUNVALLEY_2025LIST_HYBRID
UNION ALL
SELECT 'Status Types' as metric, COUNT(DISTINCT status) as value FROM SUNVALLEY_2025LIST_HYBRID;
