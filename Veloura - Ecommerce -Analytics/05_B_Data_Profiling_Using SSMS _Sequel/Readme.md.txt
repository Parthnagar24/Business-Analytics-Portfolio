**Project:** #Veloura (Fashion & Beauty Ecommerce, India)

# What we did:
--------------------------
Examined all 7 raw tables (loaded into `staging.*` in SSMS) to identify data quality issues — without fixing anything. Followed 6 structured steps: #Structure → #Completeness → #Uniqueness → #Validity → #Consistency → #Distribution.

#Step1 — #Structure: Row counts confirmed correct load (2,02,916 rows total, matching Phase 4 generation exactly). All staging columns confirmed VARCHAR (intentional), flagged for type conversion in Phase 6.

#Step2 — #Completeness (missing values):

|Table|Column|Missing|Verdict|
|---|---|---|---|
|Customers|email|221|Fix needed|
|Customers|phone_number|168|Fix needed|
|Customers|address|113|Fix — can potentially backfill from orders.shipping_address|
|Orders|promotion_id|36,727|OK — expected (nullable, order without promo)|
|Orders|shipping_address|1,057|Fix needed|
|Order_Details|unit_price|3,008|Fix needed — breaks revenue calc|
|Reviews|review_text|994|OK — optional field|
|Products, Returns, Promotions|—|0|Clean|

#Step3 — #Uniqueness:
All primary keys confirmed unique across all 7 tables (0 duplicates). However, checking beyond IDs revealed **55 duplicate emails and 53 duplicate phone numbers** in Customers — same real person re-registered under a new customer_id. Key lesson: unique IDs don't guarantee unique real-world records.

#Step4 — #Validity:
- `order_details.quantity`: 1,022 rows ≤ 0 (includes -1 and 0)
- `reviews.rating`: 662 rows outside 1–5 range (-1, 0, 6)
- `products` prices: no invalid values found
- Return-before-order logic check: 45 genuine violations (return_date earlier than order_date) after correcting for mixed date-format string comparison
- Future-date check on orders: performed, pending final confirmation

#Step 5 — #Consistency:

- Categorical values (state, order_status, category, return_reason, promotion_type): no case-sensitivity issue confirmed under default collation; flagged as **pending re-verification with case-sensitive collation**, since SQL Server's default collation can mask real casing differences
- Whitespace found in 166 `first_name` values
- Phone number formats: 5 distinct styles found (plain 10-digit, +91-dash, leading zero, dash-split, unrecognized); pending final correction/re-run on the dash-split pattern match
- Date format distribution (order_date, return_date): confirmed exactly 5 known formats account for 100% of rows in both columns — no unrecognized junk

#Step6 — #Distribution:
- Quantity, price, and order-total distributions are right-skewed (mean > median) — expected for ecommerce data, not an error
- Category-level pricing confirmed consistent cost-to-selling ratio (0.55) across all 5 categories
- Rating distribution (662 invalid + valid 1–5 skew of ~38/30/18/9/5%) matches the design weights from Phase 4 almost exactly
- IQR outlier check flagged high-value orders above ~₹7,238 — reviewed and considered plausible (multi-item purchases), not treated as errors



# Consolidated Issue Log for Phase 6 (Cleaning):
--------------------------------------------

1. Convert all VARCHAR columns to proper types (INT, DECIMAL, DATE) across all 7 tables
2. Fix missing email/phone/address in Customers (investigate backfill from Orders where possible)
3. Fix missing shipping_address (1,057) and unit_price (3,008)
4. Resolve 55 duplicate emails / 53 duplicate phone numbers — decide which customer_id to keep
5. Handle invalid quantity (1,022 rows ≤ 0) and invalid rating (662 rows outside 1–5)
6. Standardize 5 mixed date formats into one consistent DATE type across all date columns
7. Investigate 45 return-before-order logical violations — decide to exclude or flag
8. Standardize phone number formats into one consistent pattern
9. Trim whitespace in first_name (and check last_name/other text fields similarly)
10. Verify order_total_amount vs. SUM(order_details.total_price) mismatch (from Phase 3 validation rule) — not yet explicitly re-checked in Phase 5, should be first task in Phase 6
