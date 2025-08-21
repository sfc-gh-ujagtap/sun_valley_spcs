-- Sun Valley 2025 Contact Management Database Setup Script
-- This script creates the database, schema, and tables required for the Sun Valley Contact Management app

-- Create database and schema
CREATE DATABASE IF NOT EXISTS SUN_VALLEY;
CREATE SCHEMA IF NOT EXISTS SUN_VALLEY.Y2025;

-- Use the schema
USE DATABASE SUN_VALLEY;
USE SCHEMA Y2025;

-- Drop table if exists (for clean recreation)
DROP TABLE IF EXISTS SUNVALLEY_2025LIST_HYBRID;

-- Create the main hybrid table for Sun Valley 2025 contacts
CREATE OR REPLACE HYBRID TABLE SUNVALLEY_2025LIST_HYBRID (
    ID NUMBER AUTOINCREMENT,
    NAME VARCHAR(16777216),
    COMPANY VARCHAR(16777216),
    TITLE VARCHAR(16777216),
    NEW VARCHAR(16777216),
    STATUS VARCHAR(16777216),
    PRIMARY KEY (ID)
);

-- Insert realistic mock data for Sun Valley 2025 contacts
-- Tech industry leaders, investors, CEOs, and other high-profile attendees
INSERT INTO SUNVALLEY_2025LIST_HYBRID (NAME, COMPANY, TITLE, NEW, STATUS) VALUES
    ('Amodei, Dario', 'Anthropic', 'CEO & Co-Founder', 'AI Safety Pioneer', 'Confirmed'),
    ('Altman, Sam', 'OpenAI', 'CEO', 'ChatGPT Creator', 'Confirmed'),
    ('Hassabis, Demis', 'DeepMind', 'CEO & Co-Founder', 'AlphaGo/AlphaFold', 'Confirmed'),
    ('Zuckerberg, Mark', 'Meta', 'CEO & Founder', 'Metaverse Focus', 'Pending'),
    ('Musk, Elon', 'Tesla/SpaceX/X', 'CEO', 'Multi-company Leader', 'Find at event'),
    ('Pichai, Sundar', 'Google', 'CEO', 'Bard/Gemini Lead', 'Confirmed'),
    ('Nadella, Satya', 'Microsoft', 'CEO', 'Azure/Copilot', 'Confirmed'),
    ('Benioff, Marc', 'Salesforce', 'Chairman & CEO', 'Einstein AI', 'Pending'),
    ('Huang, Jensen', 'NVIDIA', 'CEO & Founder', 'AI Chip Leader', 'Investor meeting'),
    ('Su, Lisa', 'AMD', 'CEO', 'Semiconductor Innovation', 'Confirmed'),
    
    -- Venture Capitalists and Investors
    ('Andreessen, Marc', 'Andreessen Horowitz', 'Co-Founder', 'a16z Partner', 'Confirmed'),
    ('Horowitz, Ben', 'Andreessen Horowitz', 'Co-Founder', 'a16z Partner', 'Confirmed'),
    ('Thiel, Peter', 'Founders Fund', 'Founder', 'PayPal Co-founder', 'Pending'),
    ('Doerr, John', 'Kleiner Perkins', 'Chairman', 'Legendary VC', 'Find at event'),
    ('Conway, Ron', 'SV Angel', 'Founding Partner', 'Angel Investor', 'Confirmed'),
    ('Gurley, Bill', 'Benchmark', 'General Partner', 'Uber Early Investor', 'n/a'),
    ('Lee, Aileen', 'Cowboy Ventures', 'Founder', 'Unicorn Coiner', 'Confirmed'),
    ('Chen, Steve', 'YouTube', 'Co-Founder', 'Video Platform Pioneer', 'Pending'),
    
    -- Startup Founders and Tech Leaders
    ('Chesky, Brian', 'Airbnb', 'CEO & Co-Founder', 'Sharing Economy', 'Confirmed'),
    ('Gebbia, Joe', 'Airbnb', 'Co-Founder', 'Design Focus', 'Pending'),
    ('Kalanick, Travis', 'CloudKitchens', 'CEO', 'Former Uber CEO', 'n/a'),
    ('Systrom, Kevin', 'Instagram', 'Co-Founder', 'Photo Sharing Pioneer', 'Find at event'),
    ('Dorsey, Jack', 'Block (Square)', 'Founder', 'Twitter Co-founder', 'Pending'),
    ('Stone, Biz', 'Twitter', 'Co-Founder', 'Social Media Pioneer', 'Confirmed'),
    ('Spiegel, Evan', 'Snap Inc.', 'CEO & Co-Founder', 'Snapchat Creator', 'Investor meeting'),
    
    -- Enterprise Software Leaders
    ('Weiss, Aaron', 'Monday.com', 'Co-Founder & CEO', 'Work Management', 'Confirmed'),
    ('Butterfield, Stewart', 'Slack', 'Co-Founder & CEO', 'Workplace Communication', 'Pending'),
    ('Yuan, Eric', 'Zoom', 'Founder & CEO', 'Video Communications', 'Confirmed'),
    ('Mathias, Michael', 'Yammer', 'Co-Founder', 'Enterprise Social', 'n/a'),
    ('Gassée, Jean-Louis', 'BeInc', 'Founder', 'Apple Veteran', 'Find at event'),
    
    -- AI and Machine Learning Specialists
    ('Ng, Andrew', 'Landing AI', 'Founder & CEO', 'AI Education Pioneer', 'Confirmed'),
    ('Bengio, Yoshua', 'Mila', 'Scientific Director', 'Deep Learning Pioneer', 'Investor meeting'),
    ('LeCun, Yann', 'Meta AI', 'Chief AI Scientist', 'Turing Award Winner', 'Pending'),
    ('Russell, Stuart', 'UC Berkeley', 'Professor', 'AI Safety Expert', 'Confirmed'),
    ('Sutskever, Ilya', 'Safe Superintelligence', 'Co-Founder', 'Former OpenAI CTO', 'Find at event'),
    
    -- Media and Content Leaders
    ('Wojcicki, Susan', 'YouTube', 'Former CEO', 'Video Platform Leader', 'n/a'),
    ('Thompson, Ben', 'Stratechery', 'Founder', 'Tech Analysis', 'Confirmed'),
    ('Swisher, Kara', 'Vox Media', 'Host', 'Tech Journalist', 'Pending'),
    ('Galloway, Scott', 'NYU Stern', 'Professor', 'Tech Critic', 'Confirmed'),
    
    -- Cloud and Infrastructure
    ('Jassy, Andy', 'Amazon', 'CEO', 'Former AWS CEO', 'Pending'),
    ('Kurian, Thomas', 'Google Cloud', 'CEO', 'Enterprise Focus', 'Investor meeting'),
    ('Gelsinger, Pat', 'Intel', 'CEO', 'Chip Manufacturing', 'Confirmed'),
    ('Reynolds, Kim', 'Snowflake', 'CEO', 'Data Cloud Pioneer', 'Confirmed'),
    
    -- Fintech and Blockchain
    ('Lutke, Tobias', 'Shopify', 'CEO', 'E-commerce Platform', 'Pending'),
    ('Collison, Patrick', 'Stripe', 'Co-Founder & CEO', 'Payment Processing', 'Confirmed'),
    ('Collison, John', 'Stripe', 'Co-Founder', 'Payment Processing', 'Confirmed'),
    ('Armstrong, Brian', 'Coinbase', 'CEO & Co-Founder', 'Crypto Exchange', 'Find at event'),
    ('Wood, Cathie', 'ARK Invest', 'CEO', 'Disruptive Innovation', 'n/a'),
    
    -- International Tech Leaders
    ('Zhang, Yiming', 'ByteDance', 'Founder', 'TikTok Creator', 'Pending'),
    ('Ma, Jack', 'Alibaba', 'Co-Founder', 'E-commerce Pioneer', 'n/a'),
    ('Lei, Jun', 'Xiaomi', 'Founder & CEO', 'Smartphone Innovation', 'Find at event'),
    ('Mikitani, Hiroshi', 'Rakuten', 'Chairman & CEO', 'Japanese E-commerce', 'Confirmed'),
    
    -- Emerging Leaders and Rising Stars
    ('Garg, Vishal', 'Better.com', 'CEO', 'Digital Mortgage', 'Pending'),
    ('Hunt, Christina', 'Catalyst Partners', 'Managing Partner', 'Healthcare VC', 'Confirmed'),
    ('Johnson, Melinda', 'TechStars', 'Managing Director', 'Startup Accelerator', 'Investor meeting'),
    ('Patel, Ravi', 'CloudScale Ventures', 'General Partner', 'Cloud Infrastructure VC', 'Confirmed'),
    ('Williams, Sarah', 'NextGen AI', 'Founder & CEO', 'AI Healthcare Startup', 'Pending'),
    
    -- Additional Notable Figures
    ('Cuban, Mark', 'Dallas Mavericks', 'Owner', 'Shark Tank Investor', 'Find at event'),
    ('Branson, Richard', 'Virgin Group', 'Founder', 'Space Tourism', 'n/a'),
    ('Case, Steve', 'Revolution', 'Chairman & CEO', 'AOL Co-founder', 'Pending'),
    ('Hoffman, Reid', 'LinkedIn', 'Co-Founder', 'Professional Network', 'Confirmed'),
    ('Parker, Sean', 'Facebook/Napster', 'Co-Founder', 'Platform Pioneer', 'Investor meeting');

-- Create some summary views for quick analysis
CREATE OR REPLACE VIEW SUN_VALLEY_STATUS_SUMMARY AS
SELECT 
    status,
    COUNT(*) as total_contacts,
    COUNT(DISTINCT company) as unique_companies
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY status 
ORDER BY total_contacts DESC;

CREATE OR REPLACE VIEW SUN_VALLEY_COMPANY_BREAKDOWN AS
SELECT 
    company,
    COUNT(*) as contact_count,
    LISTAGG(DISTINCT status, ', ') as statuses
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY company 
HAVING COUNT(*) > 1
ORDER BY contact_count DESC;

-- Grant permissions (adjust as needed for your environment)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON SUNVALLEY_2025LIST_HYBRID TO ROLE <YOUR_ROLE>;
-- GRANT SELECT ON SUN_VALLEY_STATUS_SUMMARY TO ROLE <YOUR_ROLE>;
-- GRANT SELECT ON SUN_VALLEY_COMPANY_BREAKDOWN TO ROLE <YOUR_ROLE>;

-- Show summary of created data
SELECT 'Data Summary' as info, COUNT(*) as total_contacts FROM SUNVALLEY_2025LIST_HYBRID
UNION ALL
SELECT 'Confirmed Contacts' as info, COUNT(*) FROM SUNVALLEY_2025LIST_HYBRID WHERE status = 'Confirmed'
UNION ALL
SELECT 'Pending Contacts' as info, COUNT(*) FROM SUNVALLEY_2025LIST_HYBRID WHERE status = 'Pending'
UNION ALL
SELECT 'Companies Represented' as info, COUNT(DISTINCT company) FROM SUNVALLEY_2025LIST_HYBRID;

-- Show status distribution
SELECT status, COUNT(*) as count 
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY status 
ORDER BY count DESC;
