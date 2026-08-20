# Telecom Customer & Revenue Analytics — Nigeria

An end-to-end data analytics project combining **real NCC (Nigerian Communications
Commission) complaint data** with a simulated customer base to answer six real-world
telecom business questions — built across Excel/Google Sheets, MySQL, and Power BI.

## Business Questions Answered

1. What % of revenue comes from data vs. voice vs. SMS?
2. Which regions have the highest ARPU (Average Revenue Per User)?
3. Are prepaid or postpaid customers more profitable?
4. Churn signal: which customers haven't recharged in 30+ days?
5. Which recharge channel is most popular, and does channel correlate with customer value?
6. How do MTN, Airtel, Glo, and 9mobile compare on real NCC complaint volume and resolution rate?

## Dashboard

![Telecom Analytics Dashboard](dashboard_screenshot.png)

*Built in Power BI, connected live to a MySQL database of 6 analytical views.*

## Tech Stack

- **Google Sheets / Excel** — data joining (VLOOKUP/XLOOKUP) and initial cleaning
- **MySQL** — relational schema (5 tables, foreign-key constraints) and 6 analytical views
- **Power BI** — dashboard with 5 KPI cards and 6 visuals, connected live to MySQL

## Data Sources

- **Real data:** NCC Consumer Complaint Statistics, pulled directly from the
  [NCC Market Data & Reports portal](https://ncc.gov.ng/market-data-reports/consumer-complaint-statistics)
  (February 2026 figures, plus a full-year 2025 trend).
- **Simulated data:** customer base (300 customers), recharge transactions (2,100+),
  and usage/revenue records (5,400+) — no real telecom company publishes
  customer-level data, so this layer is simulated for portfolio purposes, following
  standard practice for this type of project.

## Repository Contents

| File | Description |
|---|---|
| `telecom_analytics.sql` | Full schema — 5 tables + 6 analytical views (one per business question) |
| `dashboard_screenshot.png` | Screenshot of the final Power BI dashboard |
| `Telecom_Analytics_Study_Summary.pdf` | Full write-up: SQL code, interpretation of each view, lessons learned, and per-operator recommendations |

## Data Model

```
dim_customers ──┬── fact_recharges     (customer_id)
                └── fact_usage_revenue (customer_id)

dim_pricing         (standalone — network bundle reference pricing)
ncc_complaints      (standalone — real market-level complaint data)
```

`dim_customers` is the hub — both fact tables link to it via foreign key on
`customer_id`. `dim_pricing` and `ncc_complaints` are market/reference data,
not tied to individual simulated customers.

## Key Findings

- **Data now drives ~68% of revenue**, versus 27% for voice and under 5% for SMS —
  consistent with the well-known industry-wide shift toward data consumption.
- **ARPU is remarkably even across all 6 geopolitical zones** (within ~₦1,400 of
  each other) — revenue differences between regions come from customer *volume*,
  not per-customer spending behavior.
- **Postpaid customers generate 71% more revenue per customer than prepaid**,
  despite being only 16% of the customer base — a clear upsell/conversion target.
- **35 customers (11.7%) show a 90+ day churn risk signal** based on recharge
  recency — a concrete retention target list.
- **USSD is the dominant recharge channel** by both transaction volume and value,
  reflecting its accessibility on any phone without data or a smartphone app.
- Across the 4 real Nigerian operators, **resolution rates cluster tightly at
  96–97%**, with Airtel narrowly leading and Glo showing the highest total
  complaint volume.

See `Telecom_Analytics_Study_Summary.pdf` for the full breakdown, including the
SQL behind every finding and recommendations for each operator.

## How the Views Work

Each of the 6 SQL views answers exactly one business question, so Power BI never
queries raw tables directly — it connects straight to pre-aggregated, business-
question-shaped views. See `telecom_analytics.sql` for the full commented code.

---

*Note: NCC complaint figures are real and sourced as described above. All
customer-level data is simulated for demonstration purposes.*
