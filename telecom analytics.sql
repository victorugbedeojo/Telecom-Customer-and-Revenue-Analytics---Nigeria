-- ============================================================
-- Telecom Customer & Revenue Analytics — Nigeria
-- Database schema and analytical views
-- ============================================================

CREATE DATABASE IF NOT EXISTS telecom_analytics;
USE telecom_analytics;

-- ============================================================
-- 1. TABLES
-- ============================================================

CREATE TABLE dim_customers (
    customer_id   VARCHAR(10) PRIMARY KEY,
    state         VARCHAR(30),
    zone          VARCHAR(20),
    plan_type     VARCHAR(10),
    signup_date   DATE
);

CREATE TABLE dim_pricing (
    network          VARCHAR(20),
    bundle_name      VARCHAR(30),
    price_ngn        DECIMAL(10,2),
    data_size_gb     DECIMAL(5,2),
    validity_days    INT,
    cost_per_gb_ngn  DECIMAL(10,2)
);

CREATE TABLE fact_recharges (
    transaction_id  VARCHAR(10) PRIMARY KEY,
    customer_id     VARCHAR(10),
    date            DATE,
    amount_ngn      DECIMAL(10,2),
    channel         VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id)
);

CREATE TABLE fact_usage_revenue (
    usage_id        VARCHAR(10) PRIMARY KEY,
    customer_id     VARCHAR(10),
    month           DATE,
    service_type    VARCHAR(10),
    revenue_ngn     DECIMAL(10,2),
    volume          DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id)
);

CREATE TABLE ncc_complaints (
    operator                        VARCHAR(20),
    month                            VARCHAR(10),
    total_complaints                INT,
    resolved_complaints             INT,
    pending_complaints              INT,
    complaints_per_1000_subscribers DECIMAL(5,2)
);

-- ============================================================
-- 2. VIEWS — one per business question
-- ============================================================

-- Q1: What % of revenue comes from data vs. voice vs. SMS?
CREATE OR REPLACE VIEW vw_revenue_mix AS
SELECT
    service_type,
    SUM(revenue_ngn) AS total_revenue
FROM fact_usage_revenue
GROUP BY service_type;

-- Q2: Which regions have the highest ARPU (Average Revenue Per User)?
CREATE OR REPLACE VIEW vw_arpu_by_region AS
SELECT
    c.zone,
    SUM(u.revenue_ngn) AS total_revenue,
    COUNT(DISTINCT u.customer_id) AS active_customers,
    SUM(u.revenue_ngn) / COUNT(DISTINCT u.customer_id) AS arpu
FROM fact_usage_revenue u
JOIN dim_customers c ON u.customer_id = c.customer_id
GROUP BY c.zone;

-- Q3: Are prepaid or postpaid customers more profitable?
CREATE OR REPLACE VIEW vw_plan_profitability AS
SELECT
    c.plan_type,
    SUM(u.revenue_ngn) AS total_revenue,
    COUNT(DISTINCT u.customer_id) AS customers,
    SUM(u.revenue_ngn) / COUNT(DISTINCT u.customer_id) AS avg_revenue_per_customer
FROM fact_usage_revenue u
JOIN dim_customers c ON u.customer_id = c.customer_id
GROUP BY c.plan_type;

-- Q4: Churn signal — which customers haven't recharged in 30+ days?
CREATE OR REPLACE VIEW vw_churn_risk AS
SELECT
    c.customer_id,
    c.zone,
    c.plan_type,
    MAX(r.date) AS last_recharge_date,
    DATEDIFF(CURDATE(), MAX(r.date)) AS days_since_recharge,
    CASE
        WHEN DATEDIFF(CURDATE(), MAX(r.date)) <= 30 THEN 'Active'
        WHEN DATEDIFF(CURDATE(), MAX(r.date)) <= 60 THEN 'At Risk (30-60d)'
        WHEN DATEDIFF(CURDATE(), MAX(r.date)) <= 90 THEN 'At Risk (60-90d)'
        ELSE 'Churn Risk (90d+)'
    END AS churn_risk_tier
FROM dim_customers c
JOIN fact_recharges r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.zone, c.plan_type;

-- Q5: Which recharge channel is most popular, and does channel
--     correlate with customer value?
CREATE OR REPLACE VIEW vw_channel_value AS
SELECT
    channel,
    SUM(amount_ngn) AS total_amount,
    COUNT(*) AS transaction_count,
    SUM(amount_ngn) / COUNT(*) AS avg_amount_per_transaction
FROM fact_recharges
GROUP BY channel;

-- Q6: How do operators compare on NCC complaint volume and
--     resolution rate? (real NCC data)
CREATE OR REPLACE VIEW vw_complaints_by_operator AS
SELECT
    operator,
    SUM(total_complaints) AS total_complaints,
    SUM(resolved_complaints) AS resolved_complaints,
    SUM(pending_complaints) AS pending_complaints,
    SUM(resolved_complaints) / SUM(total_complaints) * 100 AS resolution_rate_pct
FROM ncc_complaints
GROUP BY operator;
