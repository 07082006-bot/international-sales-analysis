-- =============================================================================
-- INTERNATIONAL SALES ANALYSIS SYSTEM
-- File        : 05_stored_procedures.sql
-- Description : Reusable stored procedures for common business operations
-- Author      : Dhruv Birla
-- Version     : 1.0
-- =============================================================================

USE international_sales_db;

DELIMITER $$

-- =============================================================================
-- PROCEDURE 1: sp_country_sales_report
-- Get a full sales breakdown for any specific country
-- Usage: CALL sp_country_sales_report('India');
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_country_sales_report$$
CREATE PROCEDURE sp_country_sales_report(IN p_country_name VARCHAR(100))
BEGIN
  -- Validate: check if country exists
  IF NOT EXISTS (SELECT 1 FROM countries WHERE country_name = p_country_name) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Country not found in the database.';
  END IF;

  -- Overall summary for the country
  SELECT
    country_name,
    region,
    COUNT(transaction_id)           AS total_orders,
    SUM(quantity)                   AS units_sold,
    ROUND(SUM(net_amount_usd), 2)   AS net_revenue_usd,
    ROUND(SUM(profit_usd),     2)   AS profit_usd,
    ROUND(
      SUM(profit_usd) / SUM(net_amount_usd) * 100, 2
    )                               AS profit_margin_pct,
    COUNT(DISTINCT customer_id)     AS unique_customers
  FROM vw_sales_detail
  WHERE country_name = p_country_name
    AND status = 'Completed'
  GROUP BY country_name, region;

  -- Top 5 products in that country
  SELECT
    product_name,
    product_category,
    SUM(quantity)                   AS units_sold,
    ROUND(SUM(net_amount_usd), 2)   AS revenue_usd
  FROM vw_sales_detail
  WHERE country_name = p_country_name
    AND status = 'Completed'
  GROUP BY product_name, product_category
  ORDER BY revenue_usd DESC
  LIMIT 5;
END$$


-- =============================================================================
-- PROCEDURE 2: sp_add_sale
-- Insert a new sales transaction with basic validation
-- Usage: CALL sp_add_sale(1, 5, 2, 0.00, 1, 1.000000, '2024-01-15', 'Credit Card');
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_add_sale$$
CREATE PROCEDURE sp_add_sale(
  IN p_customer_id    INT,
  IN p_product_id     INT,
  IN p_quantity       INT,
  IN p_discount_pct   DECIMAL(5,2),
  IN p_currency_id    INT,
  IN p_exchange_rate  DECIMAL(12,6),
  IN p_sale_date      DATE,
  IN p_payment_method VARCHAR(20)
)
BEGIN
  DECLARE v_unit_price   DECIMAL(10,2);
  DECLARE v_stock        INT;
  DECLARE v_new_txn_id   INT;

  -- Fetch current product price and stock
  SELECT unit_price, stock_qty
  INTO   v_unit_price, v_stock
  FROM   products
  WHERE  product_id = p_product_id AND is_active = 1;

  -- Validate: product exists and is active
  IF v_unit_price IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Product not found or is inactive.';
  END IF;

  -- Validate: sufficient stock (skip for digital products with stock = 9999)
  IF v_stock < p_quantity AND v_stock <> 9999 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Insufficient stock for this product.';
  END IF;

  -- Insert the transaction
  INSERT INTO sales_transactions
    (customer_id, product_id, quantity, unit_price_usd, discount_pct,
     currency_id, exchange_rate, sale_date, status, payment_method)
  VALUES
    (p_customer_id, p_product_id, p_quantity, v_unit_price, p_discount_pct,
     p_currency_id, p_exchange_rate, p_sale_date, 'Completed', p_payment_method);

  SET v_new_txn_id = LAST_INSERT_ID();

  -- Deduct stock (only for physical products)
  IF v_stock <> 9999 THEN
    UPDATE products
    SET stock_qty = stock_qty - p_quantity
    WHERE product_id = p_product_id;
  END IF;

  -- Return confirmation
  SELECT
    v_new_txn_id                       AS new_transaction_id,
    ROUND(v_unit_price * p_quantity
          * (1 - p_discount_pct / 100), 2) AS net_amount_usd,
    'Sale recorded successfully'        AS message;
END$$


-- =============================================================================
-- PROCEDURE 3: sp_customer_360
-- Complete 360° profile of a customer: orders, spend, top products
-- Usage: CALL sp_customer_360(14);
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_customer_360$$
CREATE PROCEDURE sp_customer_360(IN p_customer_id INT)
BEGIN
  -- Profile header
  SELECT
    cs.customer_name,
    cs.customer_type,
    cs.customer_email,
    cs.country_name,
    cs.region,
    cs.total_orders,
    cs.lifetime_value_usd,
    cs.avg_order_value_usd,
    cs.first_purchase_date,
    cs.last_purchase_date,
    cs.customer_tier
  FROM vw_customer_summary cs
  WHERE cs.customer_id = p_customer_id;

  -- Full purchase history
  SELECT
    transaction_id,
    sale_date,
    product_name,
    product_category,
    quantity,
    ROUND(net_amount_usd, 2)  AS net_amount_usd,
    status,
    payment_method
  FROM vw_sales_detail
  WHERE customer_id = p_customer_id
  ORDER BY sale_date DESC;
END$$

DELIMITER ;

-- Quick test
CALL sp_country_sales_report('India');
