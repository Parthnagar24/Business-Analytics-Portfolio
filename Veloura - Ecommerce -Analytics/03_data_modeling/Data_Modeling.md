
# Phase 3: Data Modeling (ER Diagram)
--------------------------------------------------
**Project:** #Veloura (Fashion & Beauty Ecommerce, India)

# What we did:
----------------------
Turned the data domains identified in Phase 2 into a formal relational structure — 7 entities, their attributes, data types, primary/foreign keys, and the relationships connecting them.

**Final entities:** #Customers, #Orders, #Order_Details, #Products, #Promotions, #Returns, #Reviews  
(Full attribute list with data types is in the reference ERD image.)

# Key relationships :
---------------------------
- One Customer places many Orders. Every Order belongs to exactly one Customer. (1 : M)
- One Promotion can be used on many Orders; each Order optionally uses at most one Promotion. (1 : 0..M)
- One Order generates many Order_Details lines; each line belongs to exactly one Order. (1 : M)
- One Product appears in many Order_Details lines; each line refers to exactly one Product. (1 : M)
- One Order_Details line may result in at most one Return; a Return always belongs to exactly one Order_Details line. (1 : 0..1)
- One Order_Details line may receive at most one Review; a Review always belongs to exactly one Order_Details line, and can only exist if that line represents a genuine purchase. (1 : 0..1)

# **Business rules captured in the model:**
-------------------------------------------------
- #Reviews require a real purchase (via Order_Details) — prevents fake/competitor reviews.
- #Returns apply to a whole Order_Details line (all units of that product in that order), not partial quantities, and not the entire order — other products in the same order are unaffected.
- #Promotions apply at the cart/order level only, one promotion per order, chosen by the customer — no stacking.

# Normalization check:
------------------------------
- 1NF: passes — all attributes atomic.
- 2NF: passes — all tables use single-column surrogate keys, so no partial dependency is possible.
- 3NF: passes, with two **intentional, documented exceptions**: `order_total_amount` (Orders) and `total_price` (Order_Details) are stored values technically derivable from other data, kept deliberately for query performance and reporting convenience — not accidental redundancy. A validation rule is set: Orders.order_total_amount must always equal the sum of its Order_Details totals; this will be tested during Phase 5 (Profiling).
