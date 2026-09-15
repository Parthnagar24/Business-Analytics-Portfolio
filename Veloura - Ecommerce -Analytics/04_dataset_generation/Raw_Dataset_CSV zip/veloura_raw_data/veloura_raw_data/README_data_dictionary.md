# Veloura — Raw Dataset (Phase 4 Output)
Fashion & Beauty Ecommerce, India | Timeline: 2023-01-01 to 2026-09-15

This is intentionally **raw/messy data** — do not clean anything here. This is the
input for Phase 5 (Profiling) and Phase 6 (Cleaning). Load these as-is into staging
tables first, exactly as planned.

## Files & Row Counts
| File | Rows | Notes |
|---|---|---|
| customers.csv | 5,555 | includes ~1% intentional duplicate re-registrations |
| products.csv | 55 | 5 categories x ~11 products |
| promotions.csv | 100 | festival-anchored (recurring yearly) + generic |
| orders.csv | 52,855 | ~30.5% carry a promotion_id (matches 70:30 target) |
| order_details.csv | 100,273 | line items, junction between orders & products |
| returns.csv | 10,941 | category-based return rates applied |
| reviews.csv | 33,137 | only on delivered, purchased lines |

**Total rows across all tables: 202,916**

## Known Data Quality Issues (by design — find these in Phase 5)
- **Missing values**: email, phone_number, address (customers); shipping_address (orders);
  unit_price (order_details); review_text (reviews)
- **Inconsistent casing**: state (customers), order_status (orders), category (products),
  return_reason (returns)
- **Inconsistent date formats**: join_date, order_date, launch_date, return_date — mixed
  between ISO (YYYY-MM-DD), DD-MM-YYYY, MM/DD/YYYY, and "DD Mon YYYY" text formats
- **Duplicate records**: ~1% of customers appear twice (same person, different customer_id)
- **Whitespace issues**: leading/trailing spaces in some first_name values
- **Inconsistent phone formats**: mix of +91 prefixes, dashes, and leading zeros
- **Invalid quantities**: a small number of order_details rows have 0 or -1 quantity
- **Invalid ratings**: a small number of reviews have rating values outside 1-5 (0, 6, -1)
- **Total mismatches**: ~1.5% of orders have order_total_amount that does NOT equal
  the sum of their order_details line totals — this is the validation rule from Phase 3;
  find these during profiling before trusting revenue figures

## Business Logic Already Built In (not bugs — these are realistic patterns to discover)
- Customer behavior segments: one-time (25%), occasional (35%), regular (25%), loyal (15%)
  — each with different order frequency
- A portion of regular/loyal customers stop ordering before the end date (simulated churn)
- Order dates cluster around Indian festival periods ~40% of the time
- Return rates vary by category: Clothing/Footwear highest, Soap lowest
- Promotions apply at the order level only, one per order (never per product)
- Reviews only exist for products that were genuinely purchased (via order_details)

## Table Relationships (reference — see Phase 3 ER diagram for full detail)
- customers (1) → orders (many)
- promotions (1) → orders (many, optional)
- orders (1) → order_details (many)
- products (1) → order_details (many)
- order_details (1) → returns (0 or 1)
- order_details (1) → reviews (0 or 1)
