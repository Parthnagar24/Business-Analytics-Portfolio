Customers

email — 221 missing (4%)
phone_number — 168 missing (3%), plus format inconsistency (5 formats: plain 10-digit, +91-dash, leading zero, dash-split, +91-no-space)
address — 113 missing (2%)
state — casing inconsistency (~5% of rows: assam/Assam/ASSAM etc.)
join_date — mixed formats (~4% non-ISO)
first_name — leading/trailing whitespace (~3%)
~1% duplicate customers — same person, different customer_id (confirmed via 55 duplicate emails, 53 duplicate phones)

Orders

order_date — mixed formats (~4% non-ISO)
order_status — casing inconsistency (~5%)
shipping_address — 1,057 missing (2%)
order_total_amount — ~1.5% deliberately mismatched vs. sum of order_details (the Phase 3 validation rule)
promotion_id — NULL for ~70% of rows — this is correct/expected, not an issue (order without a promo)
A handful of rows (~4) sit 1 day past the Sept 15, 2026 cutoff — negligible generation edge case, just cap during cleaning

Order_Details

unit_price — 3,008 missing (3%)
quantity — 1,022 rows with 0 or -1 (1%)

Products

category — casing inconsistency (~6%)
launch_date — mixed formats (~4% non-ISO)

Returns

return_reason — casing inconsistency (~5%)
return_date — mixed formats (~3% non-ISO)
return_status — clean, no issue

Reviews

review_text — 994 missing (3%) — acceptable, optional field, no fix needed
rating — 662 rows invalid (-1, 0, or 6) (2%)
review_date — clean, always ISO, no issue

Promotions — fully clean, no issues at all.
