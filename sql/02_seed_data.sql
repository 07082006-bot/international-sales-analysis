-- =============================================================================
-- INTERNATIONAL SALES ANALYSIS SYSTEM
-- File        : 02_seed_data.sql
-- Description : Realistic sample data across all tables
-- Author      : Dhruv Birla
-- Version     : 1.0
-- =============================================================================

USE international_sales_db;

-- Disable FK checks during bulk insert for speed, re-enable after
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- CURRENCIES  (10 major world currencies)
-- =============================================================================
INSERT INTO currencies (currency_code, currency_name, symbol, exchange_rate, last_updated) VALUES
  ('USD', 'US Dollar',          '$',  1.000000, '2024-01-01'),
  ('EUR', 'Euro',               '€',  0.924000, '2024-01-01'),
  ('GBP', 'British Pound',      '£',  0.791000, '2024-01-01'),
  ('INR', 'Indian Rupee',       '₹',  83.120000,'2024-01-01'),
  ('JPY', 'Japanese Yen',       '¥',  141.50000,'2024-01-01'),
  ('AUD', 'Australian Dollar',  'A$', 1.530000, '2024-01-01'),
  ('CAD', 'Canadian Dollar',    'C$', 1.340000, '2024-01-01'),
  ('SGD', 'Singapore Dollar',   'S$', 1.340000, '2024-01-01'),
  ('AED', 'UAE Dirham',         'د.إ',3.672000, '2024-01-01'),
  ('BRL', 'Brazilian Real',     'R$', 4.970000, '2024-01-01');

-- =============================================================================
-- COUNTRIES  (15 countries across 5 regions)
-- =============================================================================
INSERT INTO countries (country_name, country_code, region, currency_id) VALUES
  -- Americas
  ('United States',   'US', 'Americas',     1),  -- USD
  ('Canada',          'CA', 'Americas',     7),  -- CAD
  ('Brazil',          'BR', 'Americas',    10),  -- BRL
  -- Europe
  ('Germany',         'DE', 'Europe',       2),  -- EUR
  ('France',          'FR', 'Europe',       2),  -- EUR
  ('United Kingdom',  'GB', 'Europe',       3),  -- GBP
  -- Asia
  ('India',           'IN', 'Asia',         4),  -- INR
  ('Japan',           'JP', 'Asia',         5),  -- JPY
  ('Singapore',       'SG', 'Asia',         8),  -- SGD
  -- Middle East
  ('UAE',             'AE', 'Middle East',  9),  -- AED
  -- Oceania
  ('Australia',       'AU', 'Oceania',      6);  -- AUD

-- =============================================================================
-- PRODUCT CATEGORIES  (6 categories)
-- =============================================================================
INSERT INTO product_categories (category_name, description) VALUES
  ('Electronics',      'Consumer electronics and gadgets'),
  ('Software',         'Digital licenses, SaaS subscriptions, and apps'),
  ('Accessories',      'Add-ons and peripherals for electronic devices'),
  ('Office Supplies',  'Stationery, furniture, and office equipment'),
  ('Training',         'Online courses, workshops, and certifications'),
  ('Consulting',       'Professional advisory and implementation services');

-- =============================================================================
-- PRODUCTS  (18 products across all categories)
-- =============================================================================
INSERT INTO products (product_name, category_id, unit_price, cost_price, stock_qty, sku) VALUES
  -- Electronics (cat 1)
  ('Laptop Pro 15"',          1, 1299.00, 850.00,  120, 'ELEC-LAP-001'),
  ('Wireless Headphones X1',  1,  149.00,  60.00,  350, 'ELEC-AUD-002'),
  ('4K Monitor 27"',          1,  499.00, 280.00,   80, 'ELEC-MON-003'),
  ('Mechanical Keyboard',     1,   89.00,  35.00,  200, 'ELEC-KEY-004'),
  -- Software (cat 2)
  ('Analytics Suite Pro',     2,  299.00,  20.00, 9999, 'SOFT-ANL-001'),
  ('Project Manager Lic.',    2,   99.00,   8.00, 9999, 'SOFT-PRJ-002'),
  ('Accounting Software',     2,  199.00,  15.00, 9999, 'SOFT-ACC-003'),
  ('Cloud Storage 1TB/yr',    2,   79.00,  12.00, 9999, 'SOFT-CLD-004'),
  -- Accessories (cat 3)
  ('USB-C Hub 7-in-1',        3,   49.00,  18.00,  500, 'ACC-USB-001'),
  ('Laptop Stand Aluminium',  3,   39.00,  14.00,  400, 'ACC-STD-002'),
  ('Wireless Mouse',          3,   29.00,  10.00,  600, 'ACC-MOU-003'),
  -- Office Supplies (cat 4)
  ('Ergonomic Office Chair',  4,  349.00, 180.00,   60, 'OFF-CHR-001'),
  ('Standing Desk',           4,  599.00, 310.00,   30, 'OFF-DSK-002'),
  -- Training (cat 5)
  ('Data Analytics Course',   5,  199.00,  10.00, 9999, 'TRN-DAT-001'),
  ('SQL Masterclass',         5,   99.00,   5.00, 9999, 'TRN-SQL-002'),
  ('Leadership Workshop',     5,  299.00,  30.00,  200, 'TRN-LDR-003'),
  -- Consulting (cat 6)
  ('ERP Implementation',      6, 4999.00, 1500.00,  50, 'CON-ERP-001'),
  ('Financial Advisory',      6, 2499.00,  800.00, 100, 'CON-FIN-002');

-- =============================================================================
-- CUSTOMERS  (30 customers spread across all countries)
-- =============================================================================
INSERT INTO customers (first_name, last_name, email, phone, customer_type, country_id, registered_on) VALUES
  -- USA
  ('James',    'Anderson',  'james.anderson@gmail.com',    '+1-212-555-0101', 'Individual', 1, '2022-03-15'),
  ('Sarah',    'Mitchell',  'sarah.mitchell@techcorp.com', '+1-415-555-0102', 'Business',   1, '2022-06-20'),
  ('Robert',   'Davis',     'robert.davis@outlook.com',    '+1-312-555-0103', 'Individual', 1, '2023-01-10'),
  -- Canada
  ('Emily',    'Thompson',  'emily.t@maple.ca',            '+1-416-555-0201', 'Individual', 2, '2022-07-05'),
  ('Michael',  'Brown',     'mbrown@northstar.ca',         '+1-604-555-0202', 'Business',   2, '2022-09-18'),
  -- Brazil
  ('Carlos',   'Silva',     'carlos.silva@empresa.br',     '+55-11-5555-0301','Business',   3, '2023-02-14'),
  ('Ana',      'Santos',    'ana.santos@gmail.com',        '+55-21-5555-0302','Individual', 3, '2023-05-22'),
  -- Germany
  ('Hans',     'Müller',    'hans.mueller@techde.de',      '+49-30-5550-0401','Business',   4, '2022-04-11'),
  ('Petra',    'Schmidt',   'petra.schmidt@web.de',        '+49-89-5550-0402','Individual', 4, '2023-03-30'),
  -- France
  ('Pierre',   'Dubois',    'pierre.dubois@orange.fr',     '+33-1-5550-0501', 'Individual', 5, '2022-08-25'),
  ('Claire',   'Martin',    'claire.martin@societe.fr',    '+33-6-5550-0502', 'Business',   5, '2023-01-17'),
  -- United Kingdom
  ('Oliver',   'Smith',     'oliver.smith@uk.co',          '+44-20-5550-0601','Individual', 6, '2022-05-30'),
  ('Sophie',   'Jones',     'sophie.jones@britco.co.uk',   '+44-161-5550-0602','Business',  6, '2022-11-04'),
  -- India
  ('Rahul',    'Sharma',    'rahul.sharma@infosys.in',     '+91-80-5550-0701','Business',   7, '2022-06-14'),
  ('Priya',    'Patel',     'priya.patel@gmail.com',       '+91-22-5550-0702','Individual', 7, '2023-04-08'),
  ('Arjun',    'Singh',     'arjun.singh@tcs.in',          '+91-11-5550-0703','Business',   7, '2022-12-19'),
  -- Japan
  ('Kenji',    'Tanaka',    'kenji.tanaka@sony.jp',        '+81-3-5550-0801', 'Business',   8, '2022-07-22'),
  ('Yuki',     'Yamamoto',  'yuki.yamamoto@gmail.jp',      '+81-6-5550-0802', 'Individual', 8, '2023-02-11'),
  -- Singapore
  ('Wei',      'Lim',       'wei.lim@singtel.sg',          '+65-5550-0901',   'Business',   9, '2022-10-03'),
  ('Mei',      'Chen',      'mei.chen@gmail.com',          '+65-5550-0902',   'Individual', 9, '2023-06-01'),
  -- UAE
  ('Ahmed',    'Al-Rashid', 'ahmed.alrashid@emirates.ae',  '+971-4-5550-1001','Business',  10, '2022-08-15'),
  ('Fatima',   'Hassan',    'fatima.hassan@gmail.ae',      '+971-50-5550-1002','Individual',10, '2023-03-25'),
  -- Australia
  ('Liam',     'Wilson',    'liam.wilson@ausco.com.au',    '+61-2-5550-1101', 'Business',  11, '2022-09-07'),
  ('Emma',     'Taylor',    'emma.taylor@gmail.au',        '+61-7-5550-1102', 'Individual',11, '2023-01-29'),
  -- Extra Business customers (high-value segment)
  ('TechCorp', 'Global',    'procurement@techcorp.io',     '+1-800-555-0001', 'Business',   1, '2021-11-01'),
  ('EuroTrade','GmbH',      'orders@eurotrade.de',         '+49-40-5550-0001','Business',   4, '2021-12-15'),
  ('AsiaPac',  'Solutions', 'buy@asiapac.sg',              '+65-5550-0001',   'Business',   9, '2022-01-20'),
  ('Gulf',     'Enterprises','purchasing@gulf-ent.ae',     '+971-4-5550-0001','Business',  10, '2022-02-10'),
  ('AU',       'Imports',   'trade@auimports.com.au',      '+61-3-5550-0001', 'Business',  11, '2022-03-05'),
  ('India',    'Tech Hub',  'orders@indiatechhub.in',      '+91-80-5550-0001','Business',   7, '2022-04-18');

-- =============================================================================
-- SALES TRANSACTIONS  (60 realistic transactions, Jan 2023 – Dec 2023)
-- Covers: completed sales, a few refunds, various payment methods
-- =============================================================================
INSERT INTO sales_transactions
  (customer_id, product_id, quantity, unit_price_usd, discount_pct, currency_id, exchange_rate, sale_date, status, payment_method)
VALUES
-- ── Q1 2023 ─────────────────────────────────────────────────────────────────
(1,  1,  1, 1299.00,  0.00, 1, 1.000000, '2023-01-05', 'Completed',  'Credit Card'),
(14, 6,  5,   99.00, 10.00, 4, 83.20000, '2023-01-08', 'Completed',  'Bank Transfer'),
(17, 1,  2, 1299.00,  5.00, 5, 130.5000, '2023-01-12', 'Completed',  'Bank Transfer'),
(8,  5,  3,  299.00,  0.00, 2, 0.924000, '2023-01-20', 'Completed',  'Credit Card'),
(21, 18, 1, 2499.00,  0.00, 9, 3.672000, '2023-01-25', 'Completed',  'Bank Transfer'),
(25, 17, 1, 4999.00, 15.00, 1, 1.000000, '2023-02-02', 'Completed',  'Bank Transfer'),
(12, 3,  2,  499.00,  0.00, 3, 0.791000, '2023-02-10', 'Completed',  'Credit Card'),
(19, 8,  4,   79.00,  5.00, 8, 1.340000, '2023-02-14', 'Completed',  'PayPal'),
(6,  7,  2,  199.00,  0.00, 10,4.970000, '2023-02-20', 'Completed',  'Bank Transfer'),
(16, 5,  2,  299.00, 10.00, 4, 83.20000, '2023-03-01', 'Completed',  'Bank Transfer'),
(30, 14, 8,  199.00,  0.00, 4, 83.12000, '2023-03-07', 'Completed',  'Credit Card'),
(4,  11, 3,   29.00,  0.00, 7, 1.340000, '2023-03-12', 'Completed',  'PayPal'),
(13, 13, 1,  599.00,  0.00, 3, 0.791000, '2023-03-18', 'Completed',  'Credit Card'),
(23, 6,  5,   99.00,  5.00, 6, 1.530000, '2023-03-25', 'Completed',  'Bank Transfer'),
(2,  17, 1, 4999.00, 20.00, 1, 1.000000, '2023-03-30', 'Completed',  'Bank Transfer'),

-- ── Q2 2023 ─────────────────────────────────────────────────────────────────
(10, 3,  1,  499.00,  0.00, 2, 0.924000, '2023-04-04', 'Completed',  'Credit Card'),
(15, 15, 3,   99.00,  0.00, 4, 83.12000, '2023-04-10', 'Completed',  'PayPal'),
(26, 5,  5,  299.00, 10.00, 2, 0.924000, '2023-04-15', 'Completed',  'Bank Transfer'),
(20, 9,  6,   49.00,  0.00, 8, 1.340000, '2023-04-22', 'Completed',  'PayPal'),
(7,  7,  1,  199.00,  0.00, 10,4.970000, '2023-04-28', 'Completed',  'Credit Card'),
(28, 18, 2, 2499.00,  5.00, 9, 3.672000, '2023-05-03', 'Completed',  'Bank Transfer'),
(11, 16, 4,  299.00,  0.00, 2, 0.924000, '2023-05-09', 'Completed',  'Credit Card'),
(3,  2,  2,  149.00,  0.00, 1, 1.000000, '2023-05-15', 'Completed',  'PayPal'),
(9,  8,  3,   79.00, 10.00, 2, 0.924000, '2023-05-21', 'Completed',  'Bank Transfer'),
(18, 4,  4,   89.00,  0.00, 5, 141.5000, '2023-05-27', 'Completed',  'Credit Card'),
(5,  5,  3,  299.00,  0.00, 7, 1.340000, '2023-06-02', 'Completed',  'Bank Transfer'),
(27, 17, 1, 4999.00, 10.00, 8, 1.340000, '2023-06-08', 'Completed',  'Bank Transfer'),
(22, 14, 5,  199.00,  5.00, 9, 3.672000, '2023-06-14', 'Completed',  'Credit Card'),
(1,  3,  1,  499.00,  0.00, 1, 1.000000, '2023-06-20', 'Completed',  'Credit Card'),
(14, 17, 1, 4999.00, 20.00, 4, 83.12000, '2023-06-28', 'Completed',  'Bank Transfer'),

-- ── Q3 2023 ─────────────────────────────────────────────────────────────────
(24, 2,  1,  149.00,  0.00, 6, 1.530000, '2023-07-03', 'Completed',  'PayPal'),
(8,  6, 10,   99.00, 15.00, 2, 0.924000, '2023-07-10', 'Completed',  'Bank Transfer'),
(16, 15, 2,   99.00,  0.00, 4, 83.12000, '2023-07-17', 'Completed',  'PayPal'),
(25, 5,  4,  299.00,  0.00, 1, 1.000000, '2023-07-22', 'Completed',  'Credit Card'),
(6,  18, 1, 2499.00,  0.00, 10,4.970000, '2023-07-30', 'Refunded',   'Bank Transfer'),
(19, 1,  1, 1299.00,  5.00, 8, 1.340000, '2023-08-04', 'Completed',  'Credit Card'),
(13, 9,  4,   49.00,  0.00, 3, 0.791000, '2023-08-11', 'Completed',  'PayPal'),
(29, 7,  5,  199.00,  0.00, 6, 1.530000, '2023-08-17', 'Completed',  'Bank Transfer'),
(3,  16, 2,  299.00,  0.00, 1, 1.000000, '2023-08-23', 'Completed',  'Credit Card'),
(17, 5,  3,  299.00,  5.00, 5, 141.5000, '2023-08-29', 'Completed',  'Bank Transfer'),
(21, 1,  2, 1299.00, 10.00, 9, 3.672000, '2023-09-05', 'Completed',  'Bank Transfer'),
(11, 14, 6,  199.00,  0.00, 2, 0.924000, '2023-09-12', 'Completed',  'Credit Card'),
(30, 6,  4,   99.00,  5.00, 4, 83.12000, '2023-09-18', 'Completed',  'Bank Transfer'),
(23, 13, 1,  599.00,  5.00, 6, 1.530000, '2023-09-25', 'Completed',  'Credit Card'),
(4,  10, 3,   39.00,  0.00, 7, 1.340000, '2023-09-29', 'Refunded',   'PayPal'),

-- ── Q4 2023 ─────────────────────────────────────────────────────────────────
(26, 18, 1, 2499.00,  0.00, 2, 0.924000, '2023-10-04', 'Completed',  'Bank Transfer'),
(15, 1,  1, 1299.00,  0.00, 4, 83.12000, '2023-10-10', 'Completed',  'Credit Card'),
(7,  5,  2,  299.00,  0.00, 10,4.970000, '2023-10-17', 'Completed',  'Bank Transfer'),
(12, 2,  3,  149.00,  5.00, 3, 0.791000, '2023-10-24', 'Completed',  'Credit Card'),
(28, 17, 1, 4999.00, 15.00, 9, 3.672000, '2023-11-01', 'Completed',  'Bank Transfer'),
(9,  6,  5,   99.00,  0.00, 2, 0.924000, '2023-11-08', 'Completed',  'Bank Transfer'),
(2,  3,  2,  499.00, 10.00, 1, 1.000000, '2023-11-14', 'Completed',  'Credit Card'),
(20, 8,  6,   79.00,  0.00, 8, 1.340000, '2023-11-21', 'Completed',  'PayPal'),
(5,  17, 1, 4999.00, 20.00, 7, 1.340000, '2023-11-28', 'Completed',  'Bank Transfer'),
(27, 14, 3,  199.00,  0.00, 8, 1.340000, '2023-12-05', 'Completed',  'Credit Card'),
(22, 5,  2,  299.00,  5.00, 9, 3.672000, '2023-12-12', 'Completed',  'Bank Transfer'),
(18, 1,  1, 1299.00,  0.00, 5, 141.5000, '2023-12-15', 'Completed',  'Credit Card'),
(29, 6,  8,   99.00, 10.00, 6, 1.530000, '2023-12-19', 'Completed',  'Bank Transfer'),
(1,  18, 1, 2499.00,  5.00, 1, 1.000000, '2023-12-22', 'Completed',  'Credit Card'),
(16, 17, 1, 4999.00, 25.00, 4, 83.12000, '2023-12-28', 'Completed',  'Bank Transfer');

-- Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;

-- Quick data verification
SELECT 'currencies'           AS entity, COUNT(*) AS total FROM currencies
UNION ALL
SELECT 'countries',                       COUNT(*)          FROM countries
UNION ALL
SELECT 'customers',                       COUNT(*)          FROM customers
UNION ALL
SELECT 'product_categories',              COUNT(*)          FROM product_categories
UNION ALL
SELECT 'products',                        COUNT(*)          FROM products
UNION ALL
SELECT 'sales_transactions',              COUNT(*)          FROM sales_transactions;
