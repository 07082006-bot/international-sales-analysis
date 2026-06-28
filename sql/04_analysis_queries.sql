-- =============================================================================
-- INTERNATIONAL SALES ANALYSIS SYSTEM
-- File        : 04_analysis_queries.sql
-- Description : 20 analytical queries covering revenue, products,
--               customers, and regional performance
-- Author      : Dhruv Birla
-- Version     : 1.0
-- =============================================================================

USE international_sales_db;

-- =============================================================================
-- SECTION A: REVENUE & FINANCIAL ANALYSIS
-- =============================================================================

-- ── Query A1: Overall Business KPI Summary ───────────────────────────────────
-- Top-level snapshot: total revenue, profit, margin, and order count
SELECT
  COUNT(transaction_id)            AS total_transactions,
  SUM(quantity)                    AS total_units_sold,
  ROUND(SUM(gross_amount_usd), 2)  AS total_gross_revenue_usd,
  ROUND(SUM(net_amount_usd),   2)  AS total_net_revenue_usd,
  ROUND(SUM(profit_usd),       2)  AS total_profit_usd,
  ROUND(AVG(net_amount_usd),   2)  AS avg_order_value_usd,
  ROUND(
    SUM(profit_usd) / SUM(net_amount_usd) * 100, 2
  )                                AS overall_profit_margin_pct,
  COUNT(DISTINCT customer_id)      AS unique_customers,
  COUNT(DISTINCT country_name)     AS markets_served
FROM vw_sales_detail
WHERE status = 'Completed';


-- ── Query A2: Quarterly Revenue Trend ────────────────────────────────────────
-- Compare revenue and profit across each quarter of 2023
SELECT
  sale_year,
  CONCAT('Q', sale_quarter)           AS quarter,
  COUNT(transaction_id)               AS transactions,
  ROUND(SUM(net_amount_usd),   2)     AS net_revenue_usd,
  ROUND(SUM(profit_usd),       2)     AS profit_usd,
  ROUND(
    SUM(profit_usd) / SUM(net_amount_usd) * 100, 2
  )                                   AS profit_margin_pct,
  ROUND(AVG(net_amount_usd),   2)     AS avg_order_value_usd
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY sale_year, sale_quarter
ORDER BY sale_year, sale_quarter;


-- ── Query A3: Monthly Revenue with Month-over-Month Growth ───────────────────
-- Detect growth trends using LAG() window function
SELECT
  sale_year,
  month_name,
  net_revenue_usd,
  profit_usd,
  profit_margin_pct,
  LAG(net_revenue_usd) OVER
    (ORDER BY sale_year, sale_month)    AS prev_month_revenue,
  ROUND(
    (net_revenue_usd - LAG(net_revenue_usd)
      OVER (ORDER BY sale_year, sale_month))
    / NULLIF(LAG(net_revenue_usd)
      OVER (ORDER BY sale_year, sale_month), 0) * 100, 2
  )                                     AS mom_growth_pct
FROM vw_monthly_revenue
ORDER BY sale_year, sale_month;


-- ── Query A4: Revenue by Payment Method ──────────────────────────────────────
SELECT
  payment_method,
  COUNT(transaction_id)             AS transactions,
  ROUND(SUM(net_amount_usd), 2)     AS total_revenue_usd,
  ROUND(AVG(net_amount_usd), 2)     AS avg_order_usd,
  ROUND(
    COUNT(transaction_id) * 100.0
    / SUM(COUNT(transaction_id)) OVER (), 2
  )                                 AS pct_of_transactions
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY payment_method
ORDER BY total_revenue_usd DESC;


-- ── Query A5: Discount Impact Analysis ───────────────────────────────────────
-- How much revenue is being given away as discounts?
SELECT
  CASE
    WHEN discount_pct = 0          THEN 'No Discount'
    WHEN discount_pct BETWEEN 1 AND 10  THEN 'Low (1-10%)'
    WHEN discount_pct BETWEEN 11 AND 20 THEN 'Medium (11-20%)'
    ELSE                                     'High (>20%)'
  END                              AS discount_band,
  COUNT(transaction_id)            AS transactions,
  ROUND(SUM(gross_amount_usd), 2)  AS gross_revenue_usd,
  ROUND(SUM(net_amount_usd),   2)  AS net_revenue_usd,
  ROUND(SUM(gross_amount_usd)
      - SUM(net_amount_usd), 2)    AS total_discount_given_usd,
  ROUND(AVG(profit_usd),       2)  AS avg_profit_usd
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY discount_band
ORDER BY FIELD(discount_band,
  'No Discount', 'Low (1-10%)', 'Medium (11-20%)', 'High (>20%)');


-- =============================================================================
-- SECTION B: PRODUCT & CATEGORY PERFORMANCE
-- =============================================================================

-- ── Query B1: Top 10 Products by Revenue ─────────────────────────────────────
SELECT
  product_id,
  product_name,
  product_category,
  SUM(quantity)                    AS units_sold,
  ROUND(SUM(net_amount_usd), 2)    AS total_revenue_usd,
  ROUND(SUM(profit_usd),     2)    AS total_profit_usd,
  ROUND(
    SUM(profit_usd) / SUM(net_amount_usd) * 100, 2
  )                                AS profit_margin_pct,
  ROUND(AVG(net_amount_usd), 2)    AS avg_sale_price_usd
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY product_id, product_name, product_category
ORDER BY total_revenue_usd DESC
LIMIT 10;


-- ── Query B2: Category Performance Comparison ────────────────────────────────
SELECT
  product_category,
  COUNT(DISTINCT product_id)       AS products_in_category,
  COUNT(transaction_id)            AS total_sales,
  SUM(quantity)                    AS units_sold,
  ROUND(SUM(net_amount_usd), 2)    AS total_revenue_usd,
  ROUND(SUM(profit_usd),     2)    AS total_profit_usd,
  ROUND(
    SUM(profit_usd) / SUM(net_amount_usd) * 100, 2
  )                                AS profit_margin_pct,
  -- Each category's share of total revenue
  ROUND(
    SUM(net_amount_usd) * 100.0
    / SUM(SUM(net_amount_usd)) OVER (), 2
  )                                AS revenue_share_pct
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY product_category
ORDER BY total_revenue_usd DESC;


-- ── Query B3: Product Revenue Ranking within Category ────────────────────────
-- RANK() window function: ranks products inside each category
SELECT
  product_category,
  product_name,
  ROUND(SUM(net_amount_usd), 2)    AS revenue_usd,
  RANK() OVER (
    PARTITION BY product_category
    ORDER BY SUM(net_amount_usd) DESC
  )                                AS rank_in_category
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY product_category, product_name
ORDER BY product_category, rank_in_category;


-- ── Query B4: Products with Zero Sales (Inventory Alert) ─────────────────────
-- Find active products that never appeared in any transaction
SELECT
  p.product_id,
  p.product_name,
  pc.category_name,
  p.unit_price,
  p.stock_qty,
  p.sku
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
WHERE p.is_active = 1
  AND p.product_id NOT IN (
      SELECT DISTINCT product_id
      FROM sales_transactions
      WHERE status = 'Completed'
  )
ORDER BY pc.category_name, p.product_name;


-- =============================================================================
-- SECTION C: CUSTOMER BEHAVIOUR & SEGMENTATION
-- =============================================================================

-- ── Query C1: Top 10 Customers by Lifetime Value ─────────────────────────────
SELECT
  customer_id,
  customer_name,
  customer_type,
  country_name,
  total_orders,
  total_units_bought,
  lifetime_value_usd,
  avg_order_value_usd,
  first_purchase_date,
  last_purchase_date,
  customer_tier
FROM vw_customer_summary
ORDER BY lifetime_value_usd DESC
LIMIT 10;


-- ── Query C2: Customer Tier Distribution ─────────────────────────────────────
SELECT
  customer_tier,
  COUNT(*)                          AS customer_count,
  ROUND(SUM(lifetime_value_usd), 2) AS tier_revenue_usd,
  ROUND(AVG(lifetime_value_usd), 2) AS avg_ltv_usd,
  ROUND(
    SUM(lifetime_value_usd) * 100.0
    / SUM(SUM(lifetime_value_usd)) OVER (), 2
  )                                 AS revenue_contribution_pct
FROM vw_customer_summary
GROUP BY customer_tier
ORDER BY FIELD(customer_tier, 'Platinum', 'Gold', 'Silver', 'Bronze');


-- ── Query C3: Business vs. Individual Customer Comparison ────────────────────
SELECT
  customer_type,
  COUNT(DISTINCT customer_id)      AS customers,
  COUNT(transaction_id)            AS total_orders,
  ROUND(SUM(net_amount_usd), 2)    AS total_revenue_usd,
  ROUND(AVG(net_amount_usd), 2)    AS avg_order_usd,
  ROUND(SUM(profit_usd),     2)    AS total_profit_usd
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY customer_type;


-- ── Query C4: Customer Purchase Frequency Segments ───────────────────────────
-- Segment customers: one-time buyers, repeat buyers, loyal buyers
SELECT
  CASE
    WHEN total_orders = 1  THEN 'One-Time Buyer'
    WHEN total_orders <= 3 THEN 'Repeat Buyer (2-3 orders)'
    ELSE                        'Loyal Buyer (4+ orders)'
  END                                AS frequency_segment,
  COUNT(*)                           AS customer_count,
  ROUND(AVG(lifetime_value_usd), 2)  AS avg_ltv_usd,
  ROUND(SUM(lifetime_value_usd), 2)  AS segment_revenue_usd
FROM vw_customer_summary
GROUP BY frequency_segment
ORDER BY avg_ltv_usd DESC;


-- ── Query C5: Churned Customer Alert ─────────────────────────────────────────
-- Customers who haven't purchased in the last 180 days (relative to latest sale)
SELECT
  customer_id,
  customer_name,
  customer_type,
  country_name,
  last_purchase_date,
  DATEDIFF(
    (SELECT MAX(sale_date) FROM sales_transactions),
    last_purchase_date
  )                                AS days_since_last_purchase,
  lifetime_value_usd,
  customer_tier
FROM vw_customer_summary
WHERE DATEDIFF(
    (SELECT MAX(sale_date) FROM sales_transactions),
    last_purchase_date
  ) > 180
ORDER BY lifetime_value_usd DESC;


-- =============================================================================
-- SECTION D: REGIONAL & COUNTRY ANALYSIS
-- =============================================================================

-- ── Query D1: Revenue by Region ──────────────────────────────────────────────
SELECT
  region,
  COUNT(DISTINCT country_name)      AS countries,
  COUNT(DISTINCT customer_id)       AS customers,
  COUNT(transaction_id)             AS transactions,
  ROUND(SUM(net_amount_usd),   2)   AS net_revenue_usd,
  ROUND(SUM(profit_usd),       2)   AS profit_usd,
  ROUND(
    SUM(profit_usd) / SUM(net_amount_usd) * 100, 2
  )                                 AS profit_margin_pct,
  ROUND(
    SUM(net_amount_usd) * 100.0
    / SUM(SUM(net_amount_usd)) OVER (), 2
  )                                 AS revenue_share_pct
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY region
ORDER BY net_revenue_usd DESC;


-- ── Query D2: Country-Level Revenue Ranking ───────────────────────────────────
SELECT
  country_name,
  country_code,
  region,
  currency_code,
  COUNT(DISTINCT customer_id)       AS customers,
  COUNT(transaction_id)             AS transactions,
  ROUND(SUM(net_amount_usd),   2)   AS net_revenue_usd,
  ROUND(SUM(profit_usd),       2)   AS profit_usd,
  ROUND(AVG(net_amount_usd),   2)   AS avg_order_usd,
  RANK() OVER (
    ORDER BY SUM(net_amount_usd) DESC
  )                                 AS global_revenue_rank
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY country_name, country_code, region, currency_code
ORDER BY net_revenue_usd DESC;


-- ── Query D3: Best-Selling Product per Country ────────────────────────────────
-- Uses a subquery to find the #1 product in each country by revenue
WITH country_product_rev AS (
  SELECT
    country_name,
    product_name,
    product_category,
    ROUND(SUM(net_amount_usd), 2)   AS revenue_usd,
    ROW_NUMBER() OVER (
      PARTITION BY country_name
      ORDER BY SUM(net_amount_usd) DESC
    )                               AS rn
  FROM vw_sales_detail
  WHERE status = 'Completed'
  GROUP BY country_name, product_name, product_category
)
SELECT
  country_name,
  product_name        AS top_selling_product,
  product_category,
  revenue_usd
FROM country_product_rev
WHERE rn = 1
ORDER BY revenue_usd DESC;


-- ── Query D4: Multi-Currency Revenue Summary ──────────────────────────────────
-- Shows revenue in both USD and each country's local currency
SELECT
  country_name,
  currency_code,
  currency_symbol,
  ROUND(SUM(net_amount_usd),    2)  AS revenue_usd,
  ROUND(SUM(net_amount_local),  2)  AS revenue_local_currency,
  COUNT(transaction_id)             AS transactions
FROM vw_sales_detail
WHERE status = 'Completed'
GROUP BY country_name, currency_code, currency_symbol
ORDER BY revenue_usd DESC;


-- ── Query D5: Refund Analysis by Country ─────────────────────────────────────
SELECT
  country_name,
  region,
  SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END)  AS completed,
  SUM(CASE WHEN status = 'Refunded'  THEN 1 ELSE 0 END)  AS refunded,
  COUNT(*)                                                 AS total,
  ROUND(
    SUM(CASE WHEN status = 'Refunded' THEN 1.0 ELSE 0 END)
    / COUNT(*) * 100, 2
  )                                                        AS refund_rate_pct,
  ROUND(SUM(
    CASE WHEN status = 'Refunded' THEN net_amount_usd ELSE 0 END
  ), 2)                                                    AS refunded_value_usd
FROM vw_sales_detail
GROUP BY country_name, region
HAVING refunded > 0
ORDER BY refund_rate_pct DESC;
