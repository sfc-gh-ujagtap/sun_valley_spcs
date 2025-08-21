-- Sample Analytics Queries for Sun Valley Contact Management
-- These queries demonstrate various analytics and insights you can derive from the contact data

USE DATABASE SUN_VALLEY;
USE SCHEMA Y2025;

-- 1. Status Distribution Analysis
SELECT 
    '📊 CONTACT STATUS DISTRIBUTION' as analysis_type,
    '' as separator1,
    '' as separator2;

SELECT 
    status,
    COUNT(*) as contact_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage,
    REPEAT('█', FLOOR(COUNT(*) * 20.0 / MAX(COUNT(*)) OVER())) as visual_bar
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY status
ORDER BY contact_count DESC;

-- 2. Company Representation Analysis
SELECT 
    '🏢 COMPANY REPRESENTATION' as analysis_type,
    '' as separator1,
    '' as separator2;

SELECT 
    company,
    COUNT(*) as attendees,
    LISTAGG(DISTINCT status, ', ') as status_mix,
    LISTAGG(name, '; ') as attendee_names
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY attendees DESC, company;

-- 3. Industry Category Analysis (based on company names and titles)
SELECT 
    '🏭 INDUSTRY ANALYSIS' as analysis_type,
    '' as separator1,
    '' as separator2;

SELECT 
    industry_category,
    COUNT(*) as contacts,
    COUNT(DISTINCT company) as companies,
    ROUND(AVG(CASE WHEN status = 'Confirmed' THEN 1.0 ELSE 0.0 END) * 100, 1) as confirmation_rate
FROM (
    SELECT *,
        CASE 
            WHEN UPPER(company) LIKE '%AI%' OR UPPER(company) LIKE '%ANTH%' OR UPPER(company) LIKE '%OPEN%' 
                OR UPPER(title) LIKE '%AI%' OR UPPER(title) LIKE '%ARTIFICIAL%' THEN 'Artificial Intelligence'
            WHEN UPPER(company) LIKE '%TESLA%' OR UPPER(company) LIKE '%SPACE%' OR UPPER(company) LIKE '%AUTO%' 
                OR UPPER(title) LIKE '%AUTO%' THEN 'Automotive & Space'
            WHEN UPPER(company) LIKE '%GOOGLE%' OR UPPER(company) LIKE '%META%' OR UPPER(company) LIKE '%MICROSOFT%' 
                OR UPPER(company) LIKE '%AMAZON%' THEN 'Big Tech'
            WHEN UPPER(title) LIKE '%VC%' OR UPPER(title) LIKE '%PARTNER%' OR UPPER(title) LIKE '%INVEST%' 
                OR UPPER(company) LIKE '%FUND%' OR UPPER(company) LIKE '%CAPITAL%' THEN 'Venture Capital'
            WHEN UPPER(company) LIKE '%CYBER%' OR UPPER(company) LIKE '%SECURITY%' OR UPPER(title) LIKE '%SECURITY%' 
                OR UPPER(title) LIKE '%CISO%' THEN 'Cybersecurity'
            WHEN UPPER(company) LIKE '%HEALTH%' OR UPPER(company) LIKE '%MED%' OR UPPER(company) LIKE '%BIO%' 
                OR UPPER(title) LIKE '%MEDICAL%' THEN 'Healthcare & Biotech'
            WHEN UPPER(company) LIKE '%GAME%' OR UPPER(company) LIKE '%STREAM%' OR UPPER(company) LIKE '%ENTERTAINMENT%' 
                OR UPPER(title) LIKE '%CREATIVE%' THEN 'Gaming & Entertainment'
            WHEN UPPER(company) LIKE '%GREEN%' OR UPPER(company) LIKE '%SOLAR%' OR UPPER(company) LIKE '%CARBON%' 
                OR UPPER(company) LIKE '%CLIMATE%' THEN 'Climate & Sustainability'
            WHEN UPPER(company) LIKE '%EDU%' OR UPPER(company) LIKE '%LEARN%' OR UPPER(company) LIKE '%SKILL%' 
                OR UPPER(title) LIKE '%EDUCATION%' THEN 'Education Technology'
            WHEN UPPER(company) LIKE '%QUANTUM%' OR UPPER(title) LIKE '%QUANTUM%' THEN 'Quantum Computing'
            WHEN UPPER(company) LIKE '%ROBO%' OR UPPER(company) LIKE '%AUTOMAT%' OR UPPER(title) LIKE '%ROBOT%' THEN 'Robotics'
            WHEN UPPER(company) LIKE '%FINTECH%' OR UPPER(company) LIKE '%PAYMENT%' OR UPPER(company) LIKE '%STRIPE%' 
                OR UPPER(company) LIKE '%COIN%' THEN 'Fintech & Blockchain'
            ELSE 'Other Technology'
        END as industry_category
    FROM SUNVALLEY_2025LIST_HYBRID
) categorized
GROUP BY industry_category
ORDER BY contacts DESC;

-- 4. Networking Priority Analysis
SELECT 
    '🎯 NETWORKING PRIORITIES' as analysis_type,
    '' as separator1,
    '' as separator2;

SELECT 
    status,
    COUNT(*) as contacts,
    'Priority Level: ' || 
    CASE 
        WHEN status = 'Confirmed' THEN 'HIGH - Follow up & meeting prep'
        WHEN status = 'Investor meeting' THEN 'CRITICAL - Investor pitch ready'
        WHEN status = 'Pending' THEN 'MEDIUM - Confirmation follow-up'
        WHEN status = 'Find at event' THEN 'MEDIUM - Event networking'
        ELSE 'LOW - Optional engagement'
    END as action_priority,
    CASE 
        WHEN status = 'Confirmed' THEN '✅ Schedule meetings'
        WHEN status = 'Investor meeting' THEN '💼 Prepare pitch deck'
        WHEN status = 'Pending' THEN '📞 Follow up call'
        WHEN status = 'Find at event' THEN '🤝 Event networking'
        ELSE '📋 Monitor for updates'
    END as recommended_action
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY status
ORDER BY 
    CASE status 
        WHEN 'Investor meeting' THEN 1
        WHEN 'Confirmed' THEN 2
        WHEN 'Pending' THEN 3
        WHEN 'Find at event' THEN 4
        ELSE 5
    END;

-- 5. Geographic/International Representation
SELECT 
    '🌍 INTERNATIONAL REPRESENTATION' as analysis_type,
    '' as separator1,
    '' as separator2;

SELECT 
    region,
    COUNT(*) as contacts,
    LISTAGG(DISTINCT company, ', ') as companies
FROM (
    SELECT *,
        CASE 
            WHEN UPPER(company) LIKE '%TOKYO%' OR UPPER(name) LIKE '%NAKAMURA%' OR UPPER(name) LIKE '%HIROSHI%' THEN 'Japan'
            WHEN UPPER(company) LIKE '%BERLIN%' OR UPPER(name) LIKE '%MUELLER%' OR UPPER(name) LIKE '%HANS%' THEN 'Germany'
            WHEN UPPER(company) LIKE '%SHANGHAI%' OR UPPER(name) LIKE '%CHEN%' OR UPPER(name) LIKE '%WEI%' 
                OR UPPER(name) LIKE '%ZHANG%' OR UPPER(name) LIKE '%LEI%' THEN 'China'
            WHEN UPPER(company) LIKE '%MUMBAI%' OR UPPER(name) LIKE '%PATEL%' THEN 'India'
            WHEN UPPER(company) LIKE '%SAO PAULO%' OR UPPER(name) LIKE '%SILVA%' THEN 'Brazil'
            WHEN UPPER(company) LIKE '%RAKUTEN%' OR UPPER(name) LIKE '%MIKITANI%' THEN 'Japan'
            ELSE 'United States'
        END as region
    FROM SUNVALLEY_2025LIST_HYBRID
) geographic
GROUP BY region
ORDER BY contacts DESC;

-- 6. Contact Engagement Timeline Simulation
SELECT 
    '📅 ENGAGEMENT TIMELINE' as analysis_type,
    '' as separator1,
    '' as separator2;

SELECT 
    engagement_phase,
    COUNT(*) as contacts,
    GROUP_CONCAT(DISTINCT name) as sample_contacts
FROM (
    SELECT *,
        CASE 
            WHEN status = 'Confirmed' THEN 'Phase 3: Active Engagement'
            WHEN status = 'Investor meeting' THEN 'Phase 4: Deal Discussion'
            WHEN status = 'Pending' THEN 'Phase 2: Follow-up Required'
            WHEN status = 'Find at event' THEN 'Phase 3: Event Networking'
            ELSE 'Phase 1: Initial Contact'
        END as engagement_phase
    FROM SUNVALLEY_2025LIST_HYBRID
) phased
GROUP BY engagement_phase
ORDER BY engagement_phase;

-- 7. Contact Value Assessment (based on company and role)
SELECT 
    '💎 CONTACT VALUE ASSESSMENT' as analysis_type,
    '' as separator1,
    '' as separator2;

SELECT 
    name,
    company,
    title,
    status,
    value_tier,
    strategic_importance
FROM (
    SELECT *,
        CASE 
            WHEN UPPER(title) LIKE '%CEO%' OR UPPER(title) LIKE '%FOUNDER%' THEN 'Tier 1: C-Suite/Founders'
            WHEN UPPER(title) LIKE '%CTO%' OR UPPER(title) LIKE '%CHIEF%' OR UPPER(title) LIKE '%VP%' THEN 'Tier 2: Executive Team'
            WHEN UPPER(title) LIKE '%PARTNER%' OR UPPER(title) LIKE '%DIRECTOR%' THEN 'Tier 2: Senior Leadership'
            WHEN UPPER(title) LIKE '%MANAGER%' OR UPPER(title) LIKE '%LEAD%' THEN 'Tier 3: Management'
            ELSE 'Tier 4: Individual Contributors'
        END as value_tier,
        CASE 
            WHEN UPPER(company) IN ('OPENAI', 'ANTHROPIC', 'DEEPMIND', 'META', 'GOOGLE', 'MICROSOFT', 'TESLA') 
                THEN 'CRITICAL - Major AI/Tech Leader'
            WHEN UPPER(title) LIKE '%VC%' OR UPPER(title) LIKE '%INVEST%' OR UPPER(company) LIKE '%CAPITAL%' 
                THEN 'HIGH - Funding Potential'
            WHEN status = 'Investor meeting' THEN 'HIGH - Active Deal Discussion'
            ELSE 'MEDIUM - Networking Opportunity'
        END as strategic_importance
    FROM SUNVALLEY_2025LIST_HYBRID
) assessed
ORDER BY 
    CASE value_tier 
        WHEN 'Tier 1: C-Suite/Founders' THEN 1
        WHEN 'Tier 2: Executive Team' THEN 2
        WHEN 'Tier 2: Senior Leadership' THEN 2
        WHEN 'Tier 3: Management' THEN 3
        ELSE 4
    END,
    CASE strategic_importance 
        WHEN 'CRITICAL - Major AI/Tech Leader' THEN 1
        WHEN 'HIGH - Funding Potential' THEN 2
        WHEN 'HIGH - Active Deal Discussion' THEN 2
        ELSE 3
    END;

-- 8. Final Summary Dashboard
SELECT 
    '📋 EXECUTIVE SUMMARY' as analysis_type,
    '' as separator1,
    '' as separator2;

SELECT 
    metric,
    value,
    insight
FROM (
    SELECT 'Total Contacts' as metric, COUNT(*)::VARCHAR as value, 
           'Comprehensive attendee database' as insight
    FROM SUNVALLEY_2025LIST_HYBRID
    
    UNION ALL
    
    SELECT 'Confirmed Rate', 
           ROUND(AVG(CASE WHEN status = 'Confirmed' THEN 1.0 ELSE 0.0 END) * 100, 1)::VARCHAR || '%',
           'Percentage of confirmed attendees'
    FROM SUNVALLEY_2025LIST_HYBRID
    
    UNION ALL
    
    SELECT 'Investor Meetings', 
           COUNT(*)::VARCHAR,
           'High-value investor connections'
    FROM SUNVALLEY_2025LIST_HYBRID WHERE status = 'Investor meeting'
    
    UNION ALL
    
    SELECT 'Companies Represented',
           COUNT(DISTINCT company)::VARCHAR,
           'Unique organizations in attendance'
    FROM SUNVALLEY_2025LIST_HYBRID
    
    UNION ALL
    
    SELECT 'CEO/Founder Count',
           COUNT(*)::VARCHAR,
           'Decision-maker contacts'
    FROM SUNVALLEY_2025LIST_HYBRID 
    WHERE UPPER(title) LIKE '%CEO%' OR UPPER(title) LIKE '%FOUNDER%'
) summary_stats;
