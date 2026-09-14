# Phase 2: Data Sourcing & Understanding
-----------------------------------------
**Project:** #Veloura (Fashion & Beauty Ecommerce, India)

# What we did:
--------------------
We identified what real-world information needs to exist in the data to answer our 5 key questions — without yet designing formal tables (that's Phase 5).

# Key decisions:
-------------------

- Every #return and #promotion must trace back to an order, so revenue impact can always be calculated in ₹.
- #Products cannot be repeated inside Orders directly — #Orders and #Products have a many-to-many relationship, requiring a junction table ( #OrderDetails).
- #Promotions apply at the **cart/order level only** (one promotion per order), not per individual product — a deliberate simplicity decision.
- Orders.total must always exactly equal the sum of its Order Details line totals — no mismatches allowed. This becomes a rule we test later during profiling.
- Customer "join date" vs "first order date" can differ (a customer can register before ever ordering) — noted as a real distinction to capture.
