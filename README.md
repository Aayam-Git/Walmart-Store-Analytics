# Walmart-Store-Analytics
This project delivers a comprehensive sales data analytics report for Walmart retail stores in a particular region. The analysis focuses on sales trends, customer segmentation, product performance, and operational efficiency to drive data-informed decision-making.

## Project Overview
This project involves a deep-dive analysis of retail transaction data to uncover actionable business insights. As a Business Analyst, my goal was to transform raw sales records into a structured MS SQL Server database, perform rigorous feature engineering, and execute complex T-SQL queries to identify trends, high-value customers, and departmental performance.

## Core Objectives
- **Infrastructure**: Architected a relational database schema (`RetailAnalyticsDB`) to house and analyze sales transactions.
- **Feature Engineering**: Generated new attributes (Time of Day, Day Name, Month Name) from raw timestamps to enable granular time-series analysis.
- **Exploratory Data Analysis (EDA)**: Conducted descriptive statistics to understand customer demographics, branch performance, and purchasing power.
- **Business Intelligence**: Developed T-SQL scripts to solve real-world business problems regarding sales seasonality, tax contributions, and customer segmentation.

## Key Business Findings
- **Revenue Concentration**: The 'Food and Beverages' and 'Electronic Accessories' product lines consistently outperformed other categories in gross income.
- **Customer Segmentation**: 'Member' customers demonstrated a higher frequency of purchases compared to 'Normal' customers, though average transaction value remained competitive.
- **Operational Efficiency**: The 'Afternoon' shift (12:00 PM – 4:00 PM) handles the highest volume of transactions, suggesting a need for peak-hour staffing strategies.
- **Branch Performance**: Branch A (Yangon) showed slightly higher aggregate revenue compared to Branches B and C, indicating a stronger local market presence.

<img src = "Walmart project image.png" alt="Banner image" width="1000"/>

## Script Structure & Key Features
#### The SQL script is divided into three main operational phases:

### 1. Database Architecture
- **Environment Setup**: Checks for the existence of `RetailAnalyticsDB` and creates it if missing (Idempotent design).
- **Table Definition**: Defines the `superstore_sales` table with optimized data types (`DECIMAL` for currency, `VARCHAR` for categorical data).

### 2. Feature Engineering & Data Preparation
- **Temporal Logic**: Systematically adds and populates new columns:
  - `time_of_day`: Segments sales into Morning, Afternoon, and Evening using `CASE` logic.
  - `day_name`: Extracts the day of the week using `DATENAME(WEEKDAY, ...)`.
  - `month_name`: Extracts the month using `DATENAME(MONTH, ...)`.
- **Data Integrity**: Ensures `NOT NULL` constraints on critical fields to maintain statistical accuracy.

### 3. Business Intelligence & Reporting
The script executes a suite of strategic queries categorized into four domains:

- **Generic Analysis**:
  - Mapping of distinct cities to store branches.
  
- **Product Analysis**:
  - Identification of the best-selling product lines by quantity and revenue.
  - Analysis of VAT (Value Added Tax) contributions by category.
  - "Good" vs "Bad" product classification based on average sales performance.

- **Sales Analysis**:
  - Revenue breakdown by time of day to identify peak trading hours.
  - Assessment of the most effective customer types for revenue generation.

- **Customer Analysis**:
  - Gender distribution across branches and product lines.
  - Analysis of customer satisfaction ratings tailored by time of day and day of the week.
  - Identification of the "Best Day for Ratings" per branch using Window Functions.

## Key SQL Concepts Used
- **Aggregations**: `SUM`, `AVG`, `COUNT` for summarizing metrics.
- **Window Functions**: `RANK() OVER (PARTITION BY ...)` for analyzing branch-specific performance ranking.
- **Date Functions**: `DATENAME`, `DATEPART` for extracting temporal features.
- **Conditional Logic**: `CASE` statements for time segmentation and product categorization.
- **Filtering**: `TOP` (equivalent to `LIMIT`), `HAVING`, and `WHERE` clauses for isolating key insights.
