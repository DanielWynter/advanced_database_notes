-- ============================================================
-- Exercise 1 — Find the slow query
--
-- Run this query. Look at the execution plan.
-- Is Oracle using an index? Should it?
-- ============================================================

-- Questions:
-- a) What scan type do you see? Why?
    --Full table scan: Oracle chooses this because there is no index on site_id, and even if there were, 
    --the optimizer may still prefer scanning the whole table since a large portion of rows match the condition.

-- b) site_id has values 1–5. Is this high or low cardinality?
    --This is low cardinality.
    --There are only 5 possible values for 100,000 rows, meaning many rows share the same value.

-- c) Would adding an index on site_id help? Why or why not?
    --Not really (in most cases).
    --Because of the low cardinality, an index on site_id would not be very selective.
    -- Oracle would still need to fetch a large percentage of the table’s rows, so using the index
    -- could actually be slower than a full table scan due to extra I/O (index lookup + table access).

-- ============================================================
-- Exercise 2 — Create an index and see if it helps
--
-- Create an index on visit_date.
-- Then run the range query below and check the plan.
-- ============================================================

-- Step 1: CREATE INDEX idx_patient_visits_site_id ON patient_visits(site_id);

-- Questions:
-- a) Does Oracle use the index for this range?
    --Usually yes, if the range is relatively small (e.g., last few days or weeks). 
    --Oracle can use an INDEX RANGE SCAN because only a small subset of rows matches.


-- b) Change the range to the last 7 days. Does the plan change?
    -- The result set is very small, so an index range scan is efficient.

-- c) Change to the last 700 days. What happens?
    -- The query is retrieving a large portion of the table,
    -- so scanning everything is cheaper than using the index plus table lookups.

-- d) Why does the range size affect whether Oracle uses the index?
    -- Because of selectivity:
    -- Small range → high selectivity → index is efficient
    -- Large range → low selectivity → index becomes inefficient
    -- Indexes are beneficial when they significantly reduce the number of rows accessed. 
    -- If too many rows match, the overhead of using the index (plus accessing table blocks) outweighs its benefit

-- ============================================================
-- Exercise 3 — Composite index
--
-- You often query by both patient_id AND visit_date together:
--   WHERE patient_id = 1234 AND visit_date > SYSDATE - 90
--
-- Two options:
--   Option A: Two separate indexes (one per column)
--   Option B: One composite index (patient_id, visit_date)
--
-- Create the composite index and test the query.
-- ============================================================

-- Questions:
-- a) Does the plan use the composite index?
    -- Yes

-- b) Now try querying ONLY on visit_date (no patient_id). Does the composite index get used? Why not?
    -- No (in most cases), it will not be used.
    -- Oracle cannot efficiently use the composite index because visit_date is the second column,
    -- and the first column (patient_id) is missing in the filter.

-- c) What's the rule about column order in composite indexes?
    -- The key rule is the leftmost prefix rule:
    -- Oracle can use the index only if the query includes the leading (first) column of the index
    -- It can then optionally use subsequent columns

-- ============================================================
-- Exercise 4 — Function that breaks an index
--
-- There IS an index on patient_id (from lesson 03).
-- Predict what happens when you wrap the column in a function.
-- ============================================================

-- Questions:
-- a) What scan type did the second query use?
    -- A FULL TABLE SCAN.
    -- Oracle cannot use the index when the column is wrapped in a function, so it falls back to scanning the entire table.

-- b) Why does wrapping a column in a function break index use?
    -- Because the index stores the original column values, not the result of a function like TO_CHAR(patient_id).

-- c) How would you rewrite the second query to allow index use?
    -- SELECT * FROM patient_visits WHERE patient_id = TO_NUMBER('5432');

-- ============================================================
-- Exercise 5 — Discussion: real-world scenarios
--
-- For each scenario below, decide:
--   a) Would you add an index?
--   b) On which column(s)?
--   c) Any concerns?
-- ============================================================

-- Scenario A — Reporting table (50M rows, queried by date range)
-- a) Yes, add an index
-- b) Index on visit_date (or the date column used in filters)
-- c) Concerns:
-- Since data is loaded in batch (once per night), index maintenance cost is acceptable
-- Queries are mostly range-based, so a B-tree index works well
-- If ranges are large (e.g., months), Oracle might still choose a full scan
-- For very large tables, consider partitioning by date instead of relying only on indexes
-- Conclusion: Index is beneficial because reads dominate and inserts are infrequent.

-- Scenario B — OLTP orders table (10,000 inserts/min)
-- a) Yes
-- b) Index on customer_id (high cardinality, frequent lookups)
-- Avoid or be cautious with order_status (very low cardinality: only 4 values)
-- c) Concerns:
-- Heavy insert rate → indexes slow down writes (each insert updates indexes)
-- Index on order_status is likely not useful due to low selectivity
-- If needed, consider a composite index like (customer_id, order_status) if queries commonly use both
-- Conclusion:
-- Definitely index customer_id
-- Avoid standalone index on order_status unless combined with another column

-- Scenario C — Patient table (email lookup, 5M rows)
-- a) Yes
-- b) Index on email
-- c) Concerns:
-- None significant; this is an ideal case
-- Best choice: A UNIQUE INDEX (or a unique constraint, which creates one automatically)