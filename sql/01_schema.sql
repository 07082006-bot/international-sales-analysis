-- =============================================================================
-- INTERNATIONAL SALES ANALYSIS SYSTEM
-- File        : 01_schema.sql
-- Description : Database schema — tables, constraints, and indexes
-- Author      : Dhruv Birla
-- Version     : 1.0
-- =============================================================================

-- Drop and recreate the database for a clean start
DROP DATABASE IF EXISTS international_sales_db;
CREATE DATABASE international_sales_db
  CHARACTER SET utf8mb4        -- supports all international characters
  COLLATE utf8mb4_unicode_ci;

USE international_sales_db;

-- =============================================================================
-- TABLE 1: currencies
-- Stores all supported currencies with their exchange rate to USD
-- =============================================================================
CREATE TABLE currencies (
  currency_id    INT           NOT NULL AUTO_INCREMENT,
  currency_code  CHAR(3)       NOT NULL,   -- ISO 4217 code e.g. USD, INR, EUR
  currency_name  VARCHAR(50)   NOT NULL,
  symbol         VARCHAR(5)    NOT NULL,
  exchange_rate  DECIMAL(12,6) NOT NULL,   -- Rate relative to 1 USD
  last_updated   DATE          NOT NULL,

  PRIMARY KEY (currency_id),
  UNIQUE KEY uq_currency_code (currency_code)
) COMMENT = 'ISO 4217 currency reference with live-style exchange rates';


-- =============================================================================
-- TABLE 2: countries
-- Every country the business operates in, linked to its currency
-- =============================================================================
CREATE TABLE countries (
  country_id    INT          NOT NULL AUTO_INCREMENT,
  country_name  VARCHAR(100) NOT NULL,
  country_code  CHAR(2)      NOT NULL,   -- ISO 3166-1 alpha-2 code
  region        VARCHAR(50)  NOT NULL,   -- e.g. Asia, Europe, Americas
  currency_id   INT          NOT NULL,   -- FK → currencies

  PRIMARY KEY (country_id),
  UNIQUE KEY uq_country_code (country_code),

  CONSTRAINT fk_country_currency
    FOREIGN KEY (currency_id) REFERENCES currencies (currency_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) COMMENT = 'Countries where the business has sales operations';


-- =============================================================================
-- TABLE 3: customers
-- Individual or business buyers linked to their home country
-- =============================================================================
CREATE TABLE customers (
  customer_id    INT           NOT NULL AUTO_INCREMENT,
  first_name     VARCHAR(60)   NOT NULL,
  last_name      VARCHAR(60)   NOT NULL,
  email          VARCHAR(120)  NOT NULL,
  phone          VARCHAR(20)       NULL,
  customer_type  ENUM('Individual', 'Business') NOT NULL DEFAULT 'Individual',
  country_id     INT           NOT NULL,   -- FK → countries
  registered_on  DATE          NOT NULL,
  is_active      TINYINT(1)    NOT NULL DEFAULT 1,  -- 1 = active, 0 = churned

  PRIMARY KEY (customer_id),
  UNIQUE KEY uq_customer_email (email),

  CONSTRAINT fk_customer_country
    FOREIGN KEY (country_id) REFERENCES countries (country_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  -- Index on country for fast regional queries
  INDEX idx_customer_country (country_id),
  -- Index on type for segmentation queries
  INDEX idx_customer_type (customer_type)
) COMMENT = 'All registered buyers across international markets';


-- =============================================================================
-- TABLE 4: product_categories
-- High-level groupings for products
-- =============================================================================
CREATE TABLE product_categories (
  category_id   INT          NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(80)  NOT NULL,
  description   TEXT             NULL,

  PRIMARY KEY (category_id),
  UNIQUE KEY uq_category_name (category_name)
) COMMENT = 'Product category master list';


-- =============================================================================
-- TABLE 5: products
-- Product catalogue with cost, price, and stock tracking
-- =============================================================================
CREATE TABLE products (
  product_id    INT            NOT NULL AUTO_INCREMENT,
  product_name  VARCHAR(120)   NOT NULL,
  category_id   INT            NOT NULL,   -- FK → product_categories
  unit_price    DECIMAL(10,2)  NOT NULL,   -- Listed price in USD
  cost_price    DECIMAL(10,2)  NOT NULL,   -- Our cost (for profit calc)
  stock_qty     INT            NOT NULL DEFAULT 0,
  sku           VARCHAR(30)    NOT NULL,   -- Stock Keeping Unit code
  is_active     TINYINT(1)     NOT NULL DEFAULT 1,

  PRIMARY KEY (product_id),
  UNIQUE KEY uq_product_sku (sku),

  CONSTRAINT fk_product_category
    FOREIGN KEY (category_id) REFERENCES product_categories (category_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  -- Index for category-level product queries
  INDEX idx_product_category (category_id),
  -- Index for active product filtering
  INDEX idx_product_active (is_active)
) COMMENT = 'Product catalogue with pricing and stock information';


-- =============================================================================
-- TABLE 6: sales_transactions
-- Core fact table — one row per sale
-- =============================================================================
CREATE TABLE sales_transactions (
  transaction_id    INT            NOT NULL AUTO_INCREMENT,
  customer_id       INT            NOT NULL,   -- FK → customers
  product_id        INT            NOT NULL,   -- FK → products
  quantity          INT            NOT NULL,
  unit_price_usd    DECIMAL(10,2)  NOT NULL,   -- Price at time of sale (USD)
  discount_pct      DECIMAL(5,2)   NOT NULL DEFAULT 0.00,  -- e.g. 10.00 = 10%
  currency_id       INT            NOT NULL,   -- FK → currencies (sale currency)
  exchange_rate     DECIMAL(12,6)  NOT NULL,   -- Rate at time of sale
  sale_date         DATE           NOT NULL,
  status            ENUM('Completed','Refunded','Pending') NOT NULL DEFAULT 'Completed',
  payment_method    ENUM('Credit Card','Bank Transfer','PayPal','Cash') NOT NULL,

  PRIMARY KEY (transaction_id),

  CONSTRAINT fk_sale_customer
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_sale_product
    FOREIGN KEY (product_id) REFERENCES products (product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT fk_sale_currency
    FOREIGN KEY (currency_id) REFERENCES currencies (currency_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  -- Indexes for the most common analytical queries
  INDEX idx_sale_date        (sale_date),
  INDEX idx_sale_customer    (customer_id),
  INDEX idx_sale_product     (product_id),
  INDEX idx_sale_status      (status),
  -- Composite index for date-range + status filtering (very common)
  INDEX idx_sale_date_status (sale_date, status)
) COMMENT = 'Master sales fact table — one row per transaction';


-- =============================================================================
-- Confirm all tables were created
-- =============================================================================
SELECT
  table_name       AS 'Table',
  table_rows       AS 'Approx Rows',
  table_comment    AS 'Description'
FROM information_schema.tables
WHERE table_schema = 'international_sales_db'
ORDER BY table_name;
