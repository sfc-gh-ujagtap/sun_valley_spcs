# Sun Valley Contact Management Database Scripts

This directory contains SQL scripts for setting up the database tables and mock data required by the Sun Valley Contact Management app.

## Scripts

### `setup_sun_valley_tables.sql` ⭐ **Main Setup Script**

This script creates all necessary database objects for the Sun Valley Contact Management application:

- **Database**: `SUN_VALLEY`
- **Schema**: `Y2025`
- **Main Table**: `SUNVALLEY_2025LIST_HYBRID`
- **Views**: Summary and analytics views
- **Mock Data**: Realistic contact data for Sun Valley 2025 (60+ contacts)

### `minimal_setup.sql` 🚀 **Quick Start**

A lightweight version that creates only the essential table structure with minimal test data:
- Creates the same database and table structure
- Includes only 5 basic test contacts
- Perfect for development and testing

### `add_more_data.sql` 📈 **Data Expansion**

Adds additional diverse contacts across various industries:
- **30+ additional contacts** covering cybersecurity, healthcare, education, sustainability, gaming, automotive, space tech, biotech, quantum computing, robotics, and international markets
- Updates some existing records with new information
- Provides broader industry representation

### `cleanup.sql` 🧹 **Database Cleanup**

Utility script for cleaning up or resetting the database:
- Drops views and tables in correct order
- Option to completely remove database and schema
- Useful for testing and resetting environments

### `validate_setup.sql` ✅ **Setup Validation**

Comprehensive validation script to verify database setup:
- Tests table existence and data integrity
- Validates column structure and data types
- Checks status values and ID auto-increment functionality
- Tests hybrid table operations (INSERT/UPDATE/DELETE)
- Provides summary statistics and troubleshooting info

### `sample_analytics.sql` 📈 **Analytics Examples**

Demonstrates advanced analytics and insights from contact data:
- Status distribution and engagement analysis
- Company representation and industry categorization
- Geographic and international market analysis
- Contact value assessment and networking priorities
- Executive summary dashboard queries

## Usage

### Quick Start (Recommended)
For a fast setup with minimal data:
```bash
snowsql -f minimal_setup.sql
```

### Full Setup
For complete setup with realistic data:
```bash
snowsql -f setup_sun_valley_tables.sql
```

### Expand Data (Optional)
To add more diverse contacts after initial setup:
```bash
snowsql -f add_more_data.sql
```

### Validate Setup
To verify everything is working correctly:
```bash
snowsql -f validate_setup.sql
```

### Alternative Execution Methods

#### Option 1: Run via SnowSQL
```bash
snowsql -f setup_sun_valley_tables.sql
```

#### Option 2: Run via Snowflake Web UI
1. Open Snowflake Web UI
2. Navigate to Worksheets
3. Copy and paste the contents of `setup_sun_valley_tables.sql`
4. Execute the script

#### Option 3: Run via Snowflake Native App
The script can be executed within a Snowflake Native App environment using the app's query execution capabilities.

## Database Structure

### Main Table: `SUNVALLEY_2025LIST_HYBRID`

| Column | Type | Description |
|--------|------|-------------|
| `ID` | NUMBER (AUTOINCREMENT) | Primary key, auto-generated |
| `NAME` | VARCHAR | Contact's full name |
| `COMPANY` | VARCHAR | Company/organization name |
| `TITLE` | VARCHAR | Job title/position |
| `NEW` | VARCHAR | Additional notes/information |
| `STATUS` | VARCHAR | Contact status (see below) |

### Status Values

The application supports the following status values:
- `Confirmed` - Confirmed attendee
- `Pending` - Pending confirmation
- `Investor meeting` - Scheduled for investor meetings
- `Find at event` - To be contacted at the event
- `n/a` - Not applicable/not attending

## Mock Data

### Main Setup Script
The main script includes **60+ realistic contacts** representing:

- **Tech CEOs and Founders**: Leaders from major tech companies
- **Venture Capitalists**: Partners from top VC firms
- **AI/ML Specialists**: Researchers and entrepreneurs in AI
- **Enterprise Software Leaders**: SaaS and enterprise platform founders
- **Fintech Innovators**: Financial technology pioneers
- **International Tech Leaders**: Global technology executives
- **Emerging Leaders**: Rising stars in the tech ecosystem

### Additional Data Script
The `add_more_data.sql` script adds **30+ more contacts** from:
- **Cybersecurity**: CISOs and security platform leaders
- **Healthcare Tech**: Digital health and AI diagnostics innovators
- **Education Technology**: Online learning and skill development platforms
- **Sustainability**: Climate tech and clean energy companies
- **Gaming & Entertainment**: VR/AR gaming and content platforms
- **Automotive**: Self-driving cars and EV infrastructure
- **Space Technology**: Satellite and space manufacturing companies
- **Biotech**: Gene therapy and regenerative medicine
- **Quantum Computing**: Quantum hardware and algorithms
- **Robotics**: Industrial automation and humanoid robotics
- **International Markets**: Representatives from Japan, Germany, China, India, and Brazil

## Summary Views

The script also creates helpful views for analysis:

### `SUN_VALLEY_STATUS_SUMMARY`
Provides a breakdown of contacts by status with company counts.

### `SUN_VALLEY_COMPANY_BREAKDOWN`
Shows companies with multiple attendees and their status distribution.

## Data Verification

After running the script, you can verify the setup with these queries:

```sql
-- Check total contacts by status
SELECT status, COUNT(*) as count 
FROM SUNVALLEY_2025LIST_HYBRID 
GROUP BY status 
ORDER BY count DESC;

-- View sample data
SELECT * FROM SUNVALLEY_2025LIST_HYBRID LIMIT 10;

-- Check summary statistics
SELECT * FROM SUN_VALLEY_STATUS_SUMMARY;
```

## Notes

- The hybrid table supports real-time transactional operations (INSERT/UPDATE/DELETE)
- Data is designed to be realistic and representative of a high-profile tech conference
- Status values match those used in the React application
- All company and contact information is representative but not necessarily current

## Permissions

Adjust the grant statements in the script according to your Snowflake role and security requirements.
