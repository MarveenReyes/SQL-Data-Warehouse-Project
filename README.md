# SQL-Data-Warehouse-Project
Building a modern data warehouse with PostgreSQL, including ETL Processes, data modeling, and analytics

#  SQL Data Warehouse & Analytics Project (PostgreSQL)

Welcome to my **SQL Data Warehouse & Analytics Project**!   
This project is part of my data engineering and analytics learning journey, where I built a complete PostgreSQL-based data warehouse following a guided tutorial.

It demonstrates modern data warehousing practices including data ingestion, ETL pipelines, Medallion Architecture, star schema modeling, and analytical SQL reporting.

---

##  Data Architecture (Medallion)

This project follows the **Medallion Architecture**, consisting of:

### 🔹 Bronze Layer – Raw Data
- Stores raw CSV data as received.
- No transformations applied.
- Loaded directly into PostgreSQL as staging tables.

### 🔸 Silver Layer – Cleaned & Standardized Data
- Cleans and standardizes values.
- Fixes inconsistencies, missing data, duplicates, etc.
- Prepares data for modeling.

### 🟡 Gold Layer – Analytics / Star Schema
- Contains fact and dimension tables.
- Optimized for BI and analytical SQL queries.
- Used for generating insights and reports.

---

##  Project Overview

This project implements the full lifecycle of a modern data warehouse:

1. **Data Architecture** (Bronze → Silver → Gold)  
2. **ETL Pipelines** using PostgreSQL  
3. **Data Modeling** (Star Schema)  
4. **Analytics & Reporting** using SQL  

###  Skills Demonstrated
- PostgreSQL Development  
- Data Engineering  
- ETL Pipeline Design  
- Data Modeling  
- SQL Analytics  

---

## 🛠️ Tools & Technologies

- **PostgreSQL** (database engine)  
- **pgAdmin 4** (querying & database management)  
- **CSV files** (ERP & CRM data sources)  
- **DrawIO** (architecture & modeling diagrams)  
- **Git & GitHub** (version control)  

---

##  Project Requirements

### 🔧 1. Data Engineering – Build the Data Warehouse

#### Objective  
Integrate ERP and CRM data into a PostgreSQL data warehouse to support analytics.

#### Tasks
- Import raw CSV files into PostgreSQL (Bronze).
- Clean, transform, and standardize data (Silver).
- Model unified fact & dimension tables (Gold).
- No historization required; focus on latest snapshot.

#### Deliverables
- ETL SQL scripts  
- Star schema model  
- Data catalog documentation  

---

### 📈 2. Data Analysis – Generate Insights

#### Objective  
Create SQL queries to uncover insights about:

- Customer behavior  
- Product performance  
- Sales trends  

#### Outputs
- KPI calculations  
- Summary & aggregated tables  
- Analytical SQL queries  

---

## 📂 Repository Structure
\`\`\`
data-warehouse-project/
│
├── datasets/                      # Raw CSV datasets (ERP & CRM)
│
├── docs/                          # Documentation & diagrams
│   ├── data_architecture.drawio
│   ├── data_flow.drawio
│   ├── data_models.drawio
│   ├── data_catalog.md
│   ├── naming-conventions.md
│
├── scripts/                       # PostgreSQL ETL scripts
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│
├── tests/                         # Data quality checks
│
├── README.md                      # Project overview (this file)
└── .gitignore
\`\`\`
---

##  Example Analytical Questions

- Which products generate the highest sales revenue?  
- Which customers contribute the most revenue?  
- What are the monthly and yearly sales trends?  
- Which regions or segments perform best?  
- Which product categories drive demand?

---

## 🌟 About This Project

I created this project to strengthen my skills in:

- Data Engineering  
- SQL Development  
- Data Warehousing  
- Analytical Thinking  

While I followed a guided tutorial, all SQL scripts, transformations, documentation, and modeling were implemented by me to simulate real-world workflows.

