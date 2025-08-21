-- Sun Valley Database Validation Script
-- Run this script to verify that the database setup is working correctly

USE DATABASE SUN_VALLEY;
USE SCHEMA Y2025;

-- Test 1: Verify table exists and has data
SELECT 'Table Existence Check' as test_name,
       CASE WHEN COUNT(*) > 0 THEN 'PASS ✅' ELSE 'FAIL ❌' END as result,
       COUNT(*) as contact_count
FROM SUNVALLEY_2025LIST_HYBRID;

-- Test 2: Verify all required columns exist
SELECT 'Column Check' as test_name,
       CASE WHEN COUNT(*) = 6 THEN 'PASS ✅' ELSE 'FAIL ❌' END as result,
       'Expected: 6, Found: ' || COUNT(*) as details
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'Y2025' 
AND TABLE_NAME = 'SUNVALLEY_2025LIST_HYBRID'
AND COLUMN_NAME IN ('ID', 'NAME', 'COMPANY', 'TITLE', 'NEW', 'STATUS');

-- Test 3: Verify status values are valid
SELECT 'Status Values Check' as test_name,
       CASE WHEN COUNT(*) = 0 THEN 'PASS ✅' ELSE 'FAIL ❌' END as result,
       'Invalid statuses found: ' || COUNT(*) as details
FROM SUNVALLEY_2025LIST_HYBRID 
WHERE status NOT IN ('Confirmed', 'Pending', 'Investor meeting', 'Find at event', 'n/a');

-- Test 4: Verify ID column is auto-incrementing (no nulls, all unique)
SELECT 'ID Column Check' as test_name,
       CASE WHEN null_count = 0 AND unique_count = total_count 
            THEN 'PASS ✅' ELSE 'FAIL ❌' END as result,
       'Total: ' || total_count || ', Unique: ' || unique_count || ', Nulls: ' || null_count as details
FROM (
    SELECT COUNT(*) as total_count,
           COUNT(DISTINCT id) as unique_count,
           COUNT(*) - COUNT(id) as null_count
    FROM SUNVALLEY_2025LIST_HYBRID
);

-- Test 5: Verify hybrid table functionality (can insert/update/delete)
BEGIN;
    INSERT INTO SUNVALLEY_2025LIST_HYBRID (NAME, COMPANY, TITLE, NEW, STATUS) 
    VALUES ('Test Validation', 'Test Company', 'Test Title', 'Test Note', 'Pending');
    
    SELECT 'Insert Test' as test_name,
           CASE WHEN COUNT(*) > 0 THEN 'PASS ✅' ELSE 'FAIL ❌' END as result,
           'Test record inserted' as details
    FROM SUNVALLEY_2025LIST_HYBRID 
    WHERE NAME = 'Test Validation';
    
    UPDATE SUNVALLEY_2025LIST_HYBRID 
    SET STATUS = 'Confirmed' 
    WHERE NAME = 'Test Validation';
    
    SELECT 'Update Test' as test_name,
           CASE WHEN COUNT(*) > 0 THEN 'PASS ✅' ELSE 'FAIL ❌' END as result,
           'Test record updated' as details
    FROM SUNVALLEY_2025LIST_HYBRID 
    WHERE NAME = 'Test Validation' AND STATUS = 'Confirmed';
    
    DELETE FROM SUNVALLEY_2025LIST_HYBRID 
    WHERE NAME = 'Test Validation';
    
    SELECT 'Delete Test' as test_name,
           CASE WHEN COUNT(*) = 0 THEN 'PASS ✅' ELSE 'FAIL ❌' END as result,
           'Test record deleted' as details
    FROM SUNVALLEY_2025LIST_HYBRID 
    WHERE NAME = 'Test Validation';
ROLLBACK;

-- Summary Statistics
SELECT '=== SUMMARY STATISTICS ===' as separator, '' as value1, '' as value2
UNION ALL
SELECT 'Total Contacts', COUNT(*)::VARCHAR, ''
FROM SUNVALLEY_2025LIST_HYBRID
UNION ALL
SELECT 'Unique Companies', COUNT(DISTINCT company)::VARCHAR, ''
FROM SUNVALLEY_2025LIST_HYBRID
UNION ALL
SELECT 'Status Distribution', '', ''
UNION ALL
SELECT '  ' || status, COUNT(*)::VARCHAR, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1)::VARCHAR || '%'
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY status
ORDER BY separator, value1;

-- Final validation summary
SELECT 'VALIDATION COMPLETE' as message,
       'All tests should show PASS ✅' as instruction,
       'If any test shows FAIL ❌, check the database setup' as troubleshooting;
