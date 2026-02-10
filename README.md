Snowflake Data Warehouse and Analytics Project ❄️🚀
Welcome to the Snowflake Data Warehouse project! This repository showcases a modern, cloud-native data warehousing solution using the Medallion Architecture. It covers the end-to-end journey from raw CSV ingestion to business-ready dashboards.

🏗️ Data Architecture
This project implements the Medallion Architecture to ensure data quality and reliability:

Bronze Layer: Raw data ingestion. CSV files are uploaded to Snowflake Internal Stages and loaded into tables exactly as they appear in the source.

Silver Layer: Data cleansing and standardization. Using Snowflake Scripting (Stored Procedures), we handle deduplication, gender normalization, and date parsing (converting integer dates to DATE types).

Gold Layer: The "Analytics" layer. Data is modeled into a Star Schema using optimized Views to represent Fact and Dimension tables for reporting.

📖 Project Overview
Cloud Data Engineering: Built entirely on Snowflake, utilizing Stages, File Formats, and Stored Procedures.

ETL/ELT Pipelines: Automated transformation logic to move data from Bronze to Silver.

Data Modeling: Implementation of a Star Schema (Fact/Dimension) in the Gold layer.

Data Visualization: Integrated Snowflake Dashboards to visualize Sales Trends and Customer Behavior.

🛠️ Stack & Tools
Platform: Snowflake (Free Trial Account)

Language: Snowflake SQL & Snowflake Scripting (T-SQL converted logic)

Data Modeling: Star Schema (Fact & Dimension)

Visualization: Snowflake Snowsight Dashboards

Design: DrawIO for architecture diagrams.

📂 Repository Structure
Plaintext
snowflake-dwh-project/
│
├── datasets/                # Source CSV files (ERP and CRM data)
│
├── scripts/
│   ├── setup/               # Database, Schema, and Stage creation
│   ├── bronze/              # Procedures to load raw CSVs into Bronze
│   ├── silver/              # Transformation logic (Cleaning & Normalization)
│   └── gold/                # Views for Fact and Dimension tables
│
├── dashboards/              # SQL queries used for Snowsight visualizations
│
└── README.md                # Project documentation
🚀 Key Achievements
✅ Data Engineering
Successfully handled "dirty" data by implementing TRY_TO_DATE and DATEADD logic to fix inconsistent source formats.

Automated the pipeline using Stored Procedures, allowing for one-call execution: CALL LOAD_SILVER();.

✅ Business Intelligence
Developed a Star Schema that joins disparate CRM and ERP systems into a unified DIM_CUSTOMERS view.

Calculated complex metrics like Net Sales and SCD Type 1 logic for product history.

🛡️ License
This project is licensed under the MIT License.

🌟 Connect with Me
Based on the original project by Baraa Khatib Salkini. Converted for Snowflake implementation by [Your Name].
