-- Additional Sun Valley Contact Data
-- Run this script to add more diverse contacts to the existing table

USE DATABASE SUN_VALLEY;
USE SCHEMA Y2025;

-- Insert additional contacts focusing on different industries and roles
INSERT INTO SUNVALLEY_2025LIST_HYBRID (NAME, COMPANY, TITLE, NEW, STATUS) VALUES
    -- Cybersecurity Leaders
    ('Smith, John', 'CyberShield Inc', 'CISO', 'Security Expert', 'Confirmed'),
    ('Johnson, Lisa', 'SecureNet Solutions', 'VP Security', 'Zero Trust Advocate', 'Pending'),
    ('Brown, Michael', 'ThreatWatch', 'Founder & CEO', 'APT Research', 'Investor meeting'),
    
    -- Healthcare Tech
    ('Davis, Emily', 'HealthTech Innovations', 'Chief Medical Officer', 'Digital Health Pioneer', 'Confirmed'),
    ('Wilson, Robert', 'MedAI Solutions', 'CEO', 'AI Diagnostics', 'Find at event'),
    ('Miller, Sarah', 'Telemedicine Plus', 'CTO', 'Remote Care Platform', 'Pending'),
    
    -- Education Technology
    ('Moore, David', 'EduTech Global', 'Founder', 'Online Learning Platform', 'Confirmed'),
    ('Taylor, Jessica', 'ClassroomAI', 'CPO', 'Personalized Learning', 'n/a'),
    ('Anderson, Chris', 'SkillBuilder Pro', 'CEO', 'Professional Development', 'Investor meeting'),
    
    -- Sustainability and Climate Tech
    ('Thomas, Maria', 'GreenTech Ventures', 'Managing Partner', 'Climate VC', 'Confirmed'),
    ('Jackson, Kevin', 'SolarScale Systems', 'CTO', 'Clean Energy Tech', 'Pending'),
    ('White, Amanda', 'CarbonCapture Corp', 'CEO', 'Carbon Removal Tech', 'Find at event'),
    
    -- Gaming and Entertainment
    ('Harris, Daniel', 'NextGen Gaming', 'Creative Director', 'VR/AR Games', 'Confirmed'),
    ('Martin, Rachel', 'StreamTech Media', 'CEO', 'Content Platform', 'Pending'),
    ('Thompson, Alex', 'MetaVerse Studios', 'Founder', 'Virtual Worlds', 'Investor meeting'),
    
    -- Automotive and Transportation
    ('Garcia, Carlos', 'AutonomusDrive', 'Chief Engineer', 'Self-Driving Cars', 'Confirmed'),
    ('Rodriguez, Sofia', 'ElectricMobility', 'CEO', 'EV Infrastructure', 'Find at event'),
    ('Lewis, James', 'SmartTransport', 'CTO', 'Urban Mobility Solutions', 'Pending'),
    
    -- Space Technology
    ('Lee, Michelle', 'OrbitTech Solutions', 'Founder', 'Satellite Technology', 'Confirmed'),
    ('Walker, Ryan', 'SpaceData Corp', 'CEO', 'Earth Observation', 'Investor meeting'),
    ('Hall, Jennifer', 'AstroManufacturing', 'CTO', 'Space Manufacturing', 'n/a'),
    
    -- Biotech and Life Sciences
    ('Allen, Patricia', 'BioInnovate Labs', 'CSO', 'Gene Therapy Research', 'Confirmed'),
    ('Young, Thomas', 'ProteinTech Inc', 'CEO', 'Protein Engineering', 'Pending'),
    ('King, Nicole', 'CellTherapy Solutions', 'Founder', 'Regenerative Medicine', 'Find at event'),
    
    -- Quantum Computing
    ('Wright, Steven', 'QuantumLeap Technologies', 'Chief Scientist', 'Quantum Algorithms', 'Confirmed'),
    ('Lopez, Isabella', 'QBit Systems', 'CEO', 'Quantum Hardware', 'Investor meeting'),
    ('Hill, Benjamin', 'QuantumCloud Services', 'CTO', 'Quantum Computing as a Service', 'Pending'),
    
    -- Robotics and Automation
    ('Scott, Victoria', 'RoboTech Dynamics', 'CEO', 'Industrial Robotics', 'Confirmed'),
    ('Green, Anthony', 'AI Robotics Lab', 'Research Director', 'Humanoid Robots', 'Find at event'),
    ('Adams, Samantha', 'AutomateEverything', 'Founder', 'Process Automation', 'n/a'),
    
    -- International Representatives
    ('Nakamura, Hiroshi', 'Tokyo Tech Ventures', 'Managing Director', 'Japan Market Expert', 'Confirmed'),
    ('Mueller, Hans', 'Berlin Innovation Hub', 'CEO', 'European Expansion', 'Pending'),
    ('Chen, Wei', 'Shanghai AI Institute', 'Director', 'China AI Research', 'Investor meeting'),
    ('Patel, Priya', 'Mumbai FinTech Hub', 'Founder', 'India Payments', 'Confirmed'),
    ('Silva, Carlos', 'São Paulo Startups', 'Managing Partner', 'Latin America VC', 'Find at event');

-- Update some existing records to add variety
UPDATE SUNVALLEY_2025LIST_HYBRID 
SET NEW = 'Updated: Key AI Partnership Target' 
WHERE NAME = 'Amodei, Dario';

UPDATE SUNVALLEY_2025LIST_HYBRID 
SET NEW = 'Updated: Potential Acquisition Discussion' 
WHERE NAME = 'Altman, Sam';

UPDATE SUNVALLEY_2025LIST_HYBRID 
SET STATUS = 'Investor meeting' 
WHERE NAME = 'Thiel, Peter';

-- Show updated statistics
SELECT 
    'Updated Statistics' as info,
    'Total Contacts: ' || COUNT(*) as details
FROM SUNVALLEY_2025LIST_HYBRID
UNION ALL
SELECT 
    'Status Distribution' as info,
    status || ': ' || COUNT(*) as details
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY status
ORDER BY info, details;
