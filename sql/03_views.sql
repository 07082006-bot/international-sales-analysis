-- =============================================================================
-- INTERNATIONAL SALES ANALYSIS SYSTEM
-- File        : 03_views.sql
-- Description : Reusable views that simplify analytical queries
-- Author      : Dhruv Birla
-- Version     : 1.0
-- =============================================================================

USE international_sales_db;

-- =============================================================================
-- VIEW 1: vw_sales_detail
-- Flat, denormalized view of every transaction with all descriptive columns
-- Use this as the base for most analytical queries
-- =============================================================================
CREATE OR REPLACE VIEW vw_sales_detail AS
SELECT
  st.transaction_id,
  st.sale_date,
  YEAR(st.sale_date)                                    AS sale_year,
  QUARTER(st.sale_date)                                 AS sale_quarter,
  MONTH(st.sale_date)                                   AS sale_month,
  MONTHNAME(st.sale_date)                               AS month_name,
  -- Customer info
  st.customer_id,
  CONCAT(c.first_name, ' ', c.last_name)                AS customer_name,
  c.customer_type,
  c.email                                               AS customer_email,
  -- Geography
  co.country_id,
  co.country_name,
  co.country_code,
  co.region,
  -- Product info
  st.product_id,
  p.product_name,
  pc.category_name                                      AS product_category,
  p.sku,
  -- Currency info
  cur.currency_code,
  cur.symbol                                            AS currency_symbol,
  -- Transaction details
  st.quantity,
  st.unit_price_usd,
  st.discount_pct,
  st.payment_method,
  st.status,
  st.exchange_rate,
  -- Computed columns (all in USD for cross-currency comparison)
  ROUND(st.unit_price_usd * st.quantity, 2)             AS gross_amount_usd,
  ROUND(st.unit_price_usd * st.quantity
        * (1 - st.discount_pct / 100), 2)              AS net_amount_usd,
  ROUND((st.unit_price_usd - p.cost_price)
        * st.quantity
        * (1 - st.discount_pct / 100), 2)              AS profit_usd,
  -- Amount in the transaction's local currency
  ROUND(st.unit_price_usd * st.quantity
        * (1 - st.discount_pct / 100)
        * st.exchange_rate, 2)                          AS net_amount_local

FROM sales_transactions  st
JOIN customers           c   ON st.customer_id = c.customer_id
JOIN countries           co  ON c.country_id   = co.country_id
JOIN products            p   ON st.product_id  = p.product_id
JOIN product_categories  pc  ON p.category_id  = pc.category_id
JOIN currencies          cur ON st.currency_id  = cur.currency_id;


-- =============================================================================
-- VIEW 2: vw_monthly_revenue
-- Pre-aggregated monthly revenue and profit summary
-- =============================================================================
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
  sale_year,
  sale_month,
  month_name,
  COUNT(transaction_id)         AS total_transactions,
  SUM(quantity)                 AS units_sold,
  ROUND(SUM(gross_amount_usd), 2) AS gross_revenue_usd,
  ROUND(SUM(net_amount_usd),   2) AS net_revenue_usd,
  ROUND(SUM(profit_usd),       2) AS total_profit_usd,
  ROUND(AVG(net_amount_usd),   2) AS avg_order_value_usd,
  ROUND(
    SUM(profit_usd) / NULLIF(SUM(net_amount_usd), 0) * 100, 2
  )                               AS profit_margin_pct
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY sale_year, sale_month, month_name
ORDER BY sale_year, sale_month;


-- =============================================================================
-- VIEW 3: vw_customer_summary
-- Lifetime value, order count, and segmentation per customer
-- =============================================================================
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
  customer_id,
  customer_name,
  customer_type,
  customer_email,
  country_name,
  region,
  COUNT(transaction_id)                 AS total_orders,
  SUM(quantity)                         AS total_units_bought,
  ROUND(SUM(net_amount_usd),   2)       AS lifetime_value_usd,
  ROUND(AVG(net_amount_usd),   2)       AS avg_order_value_usd,
  MIN(sale_date)                        AS first_purchase_date,
  MAX(sale_date)                        AS last_purchase_date,
  -- Customer tier based on lifetime value
  CASE
    WHEN SUM(net_amount_usd) >= 10000 THEN 'Platinum'
    WHEN SUM(net_amount_usd) >=  5000 THEN 'Gold'
    WHEN SUM(net_amount_usd) >=  1000 THEN 'Silver'
    ELSE                                    'Bronze'
  END                                   AS customer_tier
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY customer_id, customer_name, customer_type,
         customer_email, country_name, region;
