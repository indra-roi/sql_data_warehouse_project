# Snowflake Data Warehouse and Analytics Project ❄️🚀
Welcome to the Snowflake Data Warehouse project! This repository showcases a modern, cloud-native data warehousing solution using the Medallion Architecture. It covers the end-to-end journey from raw CSV ingestion to business-ready dashboards.
---
## 🏗️ Data Architecture
This project implements the Medallion Architecture to ensure data quality and reliability:

Bronze Layer: Raw data ingestion. CSV files are uploaded to Snowflake Internal Stages and loaded into tables exactly as they appear in the source.

Silver Layer: Data cleansing and standardization. Using Snowflake Scripting (Stored Procedures), we handle deduplication, gender normalization, and date parsing (converting integer dates to DATE types).

Gold Layer: The "Analytics" layer. Data is modeled into a Star Schema using optimized Views to represent Fact and Dimension tables for reporting.
---
##📖 Project Overview
Cloud Data Engineering: Built entirely on Snowflake, utilizing Stages, File Formats, and Stored Procedures.

ETL/ELT Pipelines: Automated transformation logic to move data from Bronze to Silver.

Data Modeling: Implementation of a Star Schema (Fact/Dimension) in the Gold layer.

Data Visualization: Integrated Snowflake Dashboards to visualize Sales Trends and Customer Behavior.
---
## 🛠️ Stack & Tools
Platform: Snowflake (Free Trial Account)

Language: Snowflake SQL & Snowflake Scripting (T-SQL converted logic)

Data Modeling: Star Schema (Fact & Dimension)

Visualization: Snowflake Snowsight Dashboards

Design: DrawIO for architecture diagrams.

---
## 📂 Repository Structure

data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL
│   ├── data_architecture.drawio        # Draw.io file shows the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio                # Draw.io file for the data flow diagram
│   ├── data_models.drawio              # Draw.io file for data models (star schema)
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project
```

## 🚀 Key Achievements
✅ Data Engineering
Successfully handled "dirty" data by implementing TRY_TO_DATE and DATEADD logic to fix inconsistent source formats.

Automated the pipeline using Stored Procedures, allowing for one-call execution: CALL LOAD_SILVER();.

✅ Business Intelligence
Developed a Star Schema that joins disparate CRM and ERP systems into a unified DIM_CUSTOMERS view.

Calculated complex metrics like Net Sales and SCD Type 1 logic for product history.
---

## 🛡️ License
This project is licensed under the MIT License.

---

## 🌟 Connect with Me
Name: Indranil Sinha Roy                LinkedIn: [www.linkedin.com/in/indranil-sinha-roy-7b9510216]
