Today's Challenge
-- Lesson 04: Setup
-- Create a simple accounts table for the transfer demo

DROP TABLE accounts PURGE;

CREATE TABLE accounts (
    account_id   NUMBER PRIMARY KEY,
    owner_name   VARCHAR2(50) NOT NULL,
    balance      NUMBER(10,2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO accounts VALUES (1, 'Alice',  1000.00);
INSERT INTO accounts VALUES (2, 'Bob',     500.00);
INSERT INTO accounts VALUES (3, 'Charlie', 250.00);
COMMIT;

-- Verify starting state
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
-- Expected: Alice=1000, Bob=500, Charlie=250

-- Lesson 04: Class Exercises
-- Students: work through these in order. Don't skip the verify steps.

-- ============================================================
-- EXERCISE 1: Manual transaction (warm-up)
-- ============================================================
-- Transfer $50 from Charlie (3) to Alice (1) using BEGIN / COMMIT manually.
-- Before: verify balances. After COMMIT: verify again.

-- Your SQL here:

 

-- ============================================================
-- EXERCISE 2: Catch yourself with ROLLBACK
-- ============================================================
-- Start a transfer of $10,000 from Bob (2) to Charlie (3).
-- Before committing, check the balances. Does Bob have enough?
-- Use ROLLBACK to undo. Verify balances restored.

-- Your SQL here:

 

-- ============================================================
-- EXERCISE 3: SAVEPOINT checkpoint
-- ============================================================
-- You need to:
-- 1. Add $25 to Alice's balance
-- 2. Set a savepoint
-- 3. Deduct $25 from Charlie's balance (wrong account — you meant Bob)
-- 4. Rollback to savepoint
-- 5. Deduct $25 from Bob's balance instead
-- 6. Commit

-- Your SQL here:

 

-- ============================================================
-- EXERCISE 4: Write your own stored procedure
-- ============================================================
-- Create a procedure called deposit_funds(p_account_id, p_amount)
-- It should:
-- 1. Validate that p_amount > 0 (raise error if not)
-- 2. Add p_amount to the account balance
-- 3. COMMIT on success
-- 4. ROLLBACK + re-raise on any error
-- Test it with: EXEC deposit_funds(3, 75);

-- Your SQL here:

 

-- ============================================================
-- EXERCISE 5: Discussion
-- ============================================================
-- Answer these in words (no SQL needed):

-- Q1: You're building a patient appointment booking system.
-- A booking requires:
--   a) Reserve the time slot
--   b) Create the appointment record
--   c) Send a confirmation notification
-- Which of these should be inside the transaction? Which should be outside? Why?

-- Q2: Your stored procedure calls COMMIT at the end.
-- A developer calls your procedure from inside their own larger transaction.
-- What problem does this create?

-- Q3: You have a function called calculate_copay() and a procedure called post_payment().
-- A colleague wants to use calculate_copay() inside a SELECT statement.
-- Can they? Can they do the same with post_payment()? Why or why not?

Q1: Patient Appointment Transaction

Inside the Transaction: (a) Reserve the time slot and (b) Create the appointment record. These two are logically inseparable; you shouldn’t have a booked slot without a record, and you shouldn’t have a record if the slot wasn't successfully claimed.

Outside the Transaction: (c) Send a confirmation notification. External actions like emails or SMS cannot be "rolled back." If the database transaction fails after the email is sent, the patient will show up for an appointment that doesn't exist in the system. Always trigger notifications only after a successful commit.

Q2: The "Nested" Commit Problem

When your procedure calls COMMIT, it finalizes all pending changes in the current session, not just the ones inside your procedure.

This creates two major issues:

Loss of Atomicity: The developer can no longer roll back their "larger" transaction because your procedure already forced a save to the database.

Side Effects: If the developer had other unrelated changes pending, those are now committed prematurely, potentially leaving the database in an inconsistent state if their logic wasn't finished.

Q3: Functions vs. Procedures in SELECT

Your colleague can use calculate_copay() in a SELECT statement, but they cannot use post_payment().

Functions are designed to return a value and (ideally) have no side effects, making them safe for SELECT queries.

Procedures are designed to perform actions (like INSERT or UPDATE) and do not return a single value. SQL engines prevent calling procedures within a SELECT because a query should be "read-only" and not change the state of the data while it is simply trying to display it.