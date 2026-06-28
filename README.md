# 🌍 International Sales Analysis System
### A MySQL project for analyzing global sales across countries, currencies, products, and customers

![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=flat&logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat)

---

## 📋 Table of Contents
- [Project Overview](#-project-overview)
- [Database Schema](#-database-schema)
- [Features](#-features)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Sample Queries & Outputs](#-sample-queries--outputs)
- [Stored Procedures](#-stored-procedures)
- [Key Learnings](#-key-learnings)
- [Author](#-author)

---

## 🎯 Project Overview

This project simulates a **real-world international sales database** for a company operating across **11 countries**, **5 regions**, and **10 currencies**. It is designed to answer critical business questions such as:

- Which country generates the most profit?
- Which product category has the highest margin?
- Who are our top customers by lifetime value?
- How is revenue trending month-over-month?
- Which customers are at risk of churning?

**This system is built entirely in MySQL** using industry-standard patterns including normalized schema design, foreign key constraints, reusable views, window functions (LAG, RANK, ROW_NUMBER), CTEs, and stored procedures.

---

## 🗂 Database Schema

```
┌─────────────────┐         ┌──────────────────┐
│   currencies    │◄────────│    countries      │
│─────────────────│  FK     │──────────────────│
│ currency_id  PK │         │ country_id     PK │
│ currency_code   │         │ country_name      │
│ currency_name   │         │ country_code      │
│ symbol          │         │ region            │
│ exchange_rate   │         │ currency_id    FK │
└─────────────────┘         └─────────┬────────┘
                                       │ FK
                             ┌─────────▼────────┐
                             │    customers      │
                             │──────────────────│
                             │ customer_id    PK │
                             │ first_name        │
                             │ last_name         │
                             │ email             │
                             │ customer_type     │
                             │ country_id     FK │
                             │ registered_on     │
                             └─────────┬────────┘
                                       │ FK
┌─────────────────────┐    ┌──────────▼──────────────┐
│  product_categories │◄───│   sales_transactions     │
│─────────────────────│ FK │─────────────────────────│
│ category_id      PK │    │ transaction_id        PK │
│ category_name       │    │ customer_id           FK │
│ description         │    │ product_id            FK │
└─────────────────────┘    │ currency_id           FK │
                           │ quantity                  │
┌─────────────┐            │ unit_price_usd            │
│   products  │◄───────────│ discount_pct             │
│─────────────│ FK         │ exchange_rate             │
│ product_id  │            │ sale_date                 │
│ product_name│            │ status                    │
│ category_id │            │ payment_method            │
│ unit_price  │            └──────────────────────────┘
│ cost_price  │
│ stock_qty   │
│ sku         │
└─────────────┘
```

### Tables Summary

| Table | Rows (Sample) | Description |
|-------|:---:|---|
| `currencies` | 10 | ISO 4217 codes with exchange rates |
| `countries` | 11 | Operating markets with regional grouping |
| `customers` | 30 | International buyers (Individual & Business) |
| `product_categories` | 6 | High-level product groupings |
| `products` | 18 | Full catalogue with cost and price |
| `sales_transactions` | 60 | Core fact table — one row per sale |

---

## ✨ Features

### 🔷 Schema Design
- Fully **normalized relational schema** (3NF)
- **Primary Keys, Foreign Keys, Unique Keys** on all tables
- **Indexes** on all FK columns and high-frequency filter columns
- `ENUM` types for controlled fields (status, customer_type, payment_method)
- `ON UPDATE CASCADE` for referential integrity

### 📊 Analytical Coverage
| Area | Queries |
|---|---|
| Revenue & Finance | KPI summary, quarterly trend, MoM growth, payment method split, discount impact |
| Product Analysis | Top 10 products, category comparison, zero-sales alert, revenue ranking within category |
| Customer Behaviour | Top customers by LTV, tier distribution, frequency segmentation, churn detection |
| Regional Analysis | Revenue by region, country ranking, best product per country, multi-currency view, refund rates |

### 🔧 SQL Techniques Used
- **Window Functions**: `LAG()`, `RANK()`, `ROW_NUMBER()`, `SUM() OVER()`
- **CTEs** (Common Table Expressions): `WITH … AS (…)`
- **Conditional Aggregation**: `SUM(CASE WHEN … END)`
- **Derived Metrics**: profit margin %, MoM growth %, revenue share %
- **Reusable Views**: 3 views for clean query layering
- **Stored Procedures**: 3 procedures with input validation & error handling
- **NULL Safety**: `NULLIF()` to prevent division-by-zero errors

---

## 📁 Project Structure

```
international_sales_analysis/
│
├── sql/
│   ├── 01_schema.sql              # Database & table definitions
│   ├── 02_seed_data.sql           # 10 currencies, 11 countries,
│   │                              #   30 customers, 60 transactions
│   ├── 03_views.sql               # 3 reusable analytical views
│   ├── 04_analysis_queries.sql    # 20 business analysis queries
│   └── 05_stored_procedures.sql   # 3 stored procedures
│
└── README.md                      # This file
```

---

## ⚡ Quick Start

### Prerequisites
- MySQL 8.0 or later
- MySQL Workbench, DBeaver, or any MySQL client

### Step-by-Step Setup

```bash
# 1. Clone the repository
git clone https://github.com/dhruv-birla/international-sales-analysis.git
cd international-sales-analysis

# 2. Open your MySQL client and run files in order:
source sql/01_schema.sql       -- Creates database and all 6 tables
source sql/02_seed_data.sql    -- Loads all sample data
source sql/03_views.sql        -- Creates 3 analytical views
source sql/04_analysis_queries.sql  -- Run any query you want
source sql/05_stored_procedures.sql -- Loads stored procedures
```

### Verify Installation
```sql
USE international_sales_db;
SHOW TABLES;
-- Expected: 6 tables

SELECT COUNT(*) FROM sales_transactions;
-- Expected: 60
```

---

## 📈 Sample Queries & Outputs

### Business KPI Summary
```sql
SELECT
  COUNT(transaction_id)            AS total_transactions,
  ROUND(SUM(net_amount_usd),   2)  AS total_net_revenue_usd,
  ROUND(SUM(profit_usd),       2)  AS total_profit_usd,
  ROUND(SUM(profit_usd) / SUM(net_amount_usd) * 100, 2) AS profit_margin_pct
FROM vw_sales_detail
WHERE status = 'Completed';
```
| total_transactions | total_net_revenue_usd | total_profit_usd | profit_margin_pct |
|:---:|:---:|:---:|:---:|
| 58 | 157,842.50 | 62,140.30 | 39.37% |

---

### Top Countries by Revenue
```sql
SELECT country_name, region,
  ROUND(SUM(net_amount_usd), 2) AS revenue_usd,
  RANK() OVER (ORDER BY SUM(net_amount_usd) DESC) AS rank_num
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY country_name, region
ORDER BY rank_num LIMIT 5;
```
| country_name | region | revenue_usd | rank_num |
|---|---|:---:|:---:|
| United States | Americas | 42,318.00 | 1 |
| Germany | Europe | 28,654.50 | 2 |
| India | Asia | 24,190.80 | 3 |
| United Kingdom | Europe | 18,420.30 | 4 |
| UAE | Middle East | 15,870.00 | 5 |

---

### Customer Tier Breakdown
```sql
SELECT customer_tier, COUNT(*) AS customers,
  ROUND(SUM(lifetime_value_usd), 2) AS tier_revenue_usd
FROM vw_customer_summary
GROUP BY customer_tier;
```
| customer_tier | customers | tier_revenue_usd |
|---|:---:|:---:|
| Platinum | 3 | 48,210.00 |
| Gold | 7 | 52,140.50 |
| Silver | 12 | 38,920.30 |
| Bronze | 8 | 18,571.70 |

---

## 🔧 Stored Procedures

### `sp_country_sales_report('India')`
Generates a complete sales report for any country, including top products.
```sql
CALL sp_country_sales_report('India');
```

### `sp_add_sale(customer_id, product_id, qty, discount, ...)`
Validates and inserts a new transaction, auto-deducting inventory.
```sql
CALL sp_add_sale(1, 5, 2, 10.00, 1, 1.000000, '2024-01-15', 'Credit Card');
```

### `sp_customer_360(customer_id)`
Returns a complete customer profile with full purchase history.
```sql
CALL sp_customer_360(14);
```

---

## 💡 Key Learnings

| Concept | Applied Where |
|---|---|
| Schema normalization (3NF) | 6-table relational design |
| Composite indexes | `idx_sale_date_status` for fast filtering |
| Window functions | MoM growth, rankings, revenue shares |
| CTEs | Best product per country query |
| Stored procedures + error handling | `SIGNAL SQLSTATE` for validation |
| Multi-currency analytics | Dual-amount columns (USD + local) |
| Customer segmentation | Tier + frequency + churn logic |
| NULL-safe math | `NULLIF()` for division protection |

---

## 👤 Author

**Dhruv Birla**
B.Com (International Accounts) | St. Xavier's College, Ranchi

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=flat&logo=linkedin)](https://www.linkedin.com/in/dhruv-birla-412472355)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=flat&logo=github)](https://github.com/dhruv-birla)

---

*⭐ If this project helped you, please consider starring the repository!*
